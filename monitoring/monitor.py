from prometheus_client import start_http_server, Summary, Gauge
import time
import prefect
from prefect import task, Flow

polling_interval_seconds = 30
prefectGraphQL = "http://127.0.0.1:4200"
exporter_port = 8000

client = prefect.Client()

# Project Variables
projectNumber = Gauge('project_number', 'Total count of all Prefect Projects')
projectTotal = Gauge('prefect_projects', 'Number of Projects by Name',['name'])
# Flow Variables

flowTotal = Gauge('prefect_flows', 'Total of All Flows, All Projects')
flowProjectTotal = Gauge('prefect_flows_by_project', 'Number of Flows by Project Name',['project_id', 'project_name'])
flowRunTotal = Gauge('prefect_flowruns_total', 'Number of total flow runs by flow ID', ['project_id', 'project_name'])
flowRunTotalSuccess = Gauge('prefect_flowruns_success', 'Number of successful flow runs by flow ID', ['project_id', 'project_name'])

# Main loop retrieves exports all metrics
# Each export queries GraphQL, extracts relevant info, and exports to a metrics

def getAllMetrics():
    allProjects = queryAllProjects()
    exportAllProjects(allProjects)
    exportAllFlows()
    exportFlowsByProject(allProjects)
    exportFlowRunTotal(allProjects)
    exportFlowRunSuccess(allProjects)


# Queries GraphQL for all projects. Query returns a json object, which is passed to listify.
@task
def queryAllProjects() -> list: 
    query = """
    query Projects {
        project {
            id,
            name,
            tenant_id,
        }
    }
    """
    r = client.graphql(query=query)
    
    projectList = listifyProjects.run(r)
    return projectList

#Takes input from queryAllprojects and returns a list
@task
def listifyProjects(all_Projects: object) -> list:
    projectList = []
    for proj in all_Projects['data']['project']:
        project = {
            "id": proj['id'],
            "name":  proj['name'],
            "tenant_id": proj['tenant_id']
        }
        projectList.append(project)
    return projectList


@task
def queryAllFlows() -> int: 
    query = """
        query Flows {
            flow {
                id,
                flow_group_id,
                name,
                project_id,
                is_schedule_active
            }
        }
    """
    r = client.graphql(query=query)
        
    return len(r['data']['flow'])

@task
def listifyFlows(all_Flows: object) -> list:
    flowList = []
    for flow in all_Flows['data']['flow']:
        f = {
            "id": flow['id'],
            "flow_group_id": flow['flow_group_id'],
            "name":  flow['name'],
            "project_id": flow['project_id'],
            "is_schedule_active": flow['is_schedule_active']
        }
        flowList.append(f)
    return flowList

@task
def listifyFlowRuns(all_Flows: object) -> list:
    flowRuns = []
    for flow_run in all_Flows['data']['flow_run']:
        f = {
            "id": flow_run['id'],
            "name":  flow_run['name'],
            "state": flow_run['state']
        }
        flowRuns.append(f)
    return flowRuns

# Returns all active flows in the listed project_id
@task
def queryFlowsByProject(project_id: str) -> list: 

    variables = {
        "project_id": project_id
    }

    flow_by_project_query = """
        query Flows ($project_id: uuid!){
        flow (where: {project_id: {_eq: $project_id}}) {
            id,
            flow_group_id,
            name,
            project_id,
            is_schedule_active
            }
        }
    """
    r = client.graphql(query=flow_by_project_query, variables=variables)
    projectFlows = listifyFlows.run(r)

    return projectFlows

@task
def queryFlowRunTotalByProject(project_id: str) -> list: 

    variables = {
        "project_id": project_id
    }

    query = """
    query TotalFlowRuns($project_id: uuid) {
        flow_run(where: {flow: {project_id: {_eq: $project_id}}}) {
            id,
            name,
            state
        }
    }
    """
    r = client.graphql(query=query, variables=variables)
    
    projectList = listifyFlowRuns.run(r)
    return projectList

@task
def queryFlowRunSuccessByProject(project_id: str) -> list: 
    variables = {
        "project_id": project_id
    }

    query = """
    query TotalFlowRuns($project_id: uuid) {
        flow_run(where: {flow: {project_id: {_eq: $project_id}}, state: {_eq: "Success"}}) {
            id,
            name,
            state
        }
    }
    """
    r = client.graphql(query=query, variables=variables)
    
    projectList = listifyFlowRuns.run(r)
    return projectList



@task
# Updates projectTotal metrics with the label and value of each project queried
def exportAllProjects(allProjects):
    count = 0 
    for project in allProjects:
        projectTotal.labels(project['name']).set(1)
        count += 1
    projectNumber.set(len(allProjects)) 


# Sets and exports all flow totals across all projects
@task 
def exportAllFlows():
    flowTotal.set(queryAllFlows.run())


#Updates projectTotal metrics with the label and value of each project queried
@task
def exportFlowsByProject(allProjects):
    for project in allProjects:
        project_Flows = queryFlowsByProject.run(project['id'])
        flowProjectTotal.labels(project['id'], project['name']).set(len(project_Flows))


@task
def exportFlowRunTotal(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunTotalByProject.run(project['id'])
        flowRunTotal.labels(project['id'], project['name']).set(len(project_Flows))

@task
def exportFlowRunSuccess(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunSuccessByProject.run(project['id'])
        flowRunTotalSuccess.labels(project['id'], project['name']).set(len(project_Flows))


if __name__ == '__main__':

    # Start up the server to expose the metrics.
    start_http_server(exporter_port)
    #Core loop ; retrieve metrics then wait to poll again.
    while True:
        with Flow("collect-all") as flow:
            getAllMetrics()
        flow.run()
        time.sleep(polling_interval_seconds)
