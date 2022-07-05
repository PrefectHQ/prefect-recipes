from prometheus_client import start_http_server, Summary, Gauge
import random
import time
#import flows
import os
import prefect
from prefect import task, Flow

polling_interval_seconds = 30
prefectGraphQL = "http://127.0.0.1:4200"
exporter_port = 8000

# all_Projects = []
# Create a metric to track time spent and requests made.
client = prefect.Client()

# Prometheus Variables; Type('name', 'Description')
projectTotal = Gauge('prefect_projects', 'Number of Projects',['name'])
flowTotal = Gauge('prefect_flows', 'Number of Flows by Project',['project_name', ])

def getAllMetrics():
    exportProjects()
    queryAllFlows()

# Queries GraphQL for all projects. Query returns a json object, which is passed to listify.
@task
def queryAllProjects() -> list: 
    r = client.graphql(
        {
            'query Projects': {
                'project': {
                    'id',
                    'name',
                    'tenant_id'
                }
            }
        }
    )
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
def exportProjects():
    # Updates projectTotal metrics with the label and value of each project queried
    for project in queryAllProjects.run():
        projectTotal.labels(project['name']).set(1)

@task
def queryAllFlows() -> list: 
    r = client.graphql(
        {
            'query Flows': {
                'flow': {
                    'id',
                    'flow_group_id',
                    'name',
                    'project_id',
                    'is_schedule_active'
                }
            }
        }
    )
    print (r)
    print (len(r))
    #flowList, totalFlowCount = listifyFlows(r)
    #return flowList

@task
def listifyFlows(all_Flows: object) -> list:
    flowList = []
    for flow in all_Flows['data']['project']:
        f = {
            "id": flow['id'],
            "flow_group_id": flow['flow_group_id'],
            "name":  flow['name'],
            "project_id": flow['project_id'],
            "is_schedule_active": flow['is_schedule_active']
        }
        flowList.append(f)
    return flowList, len(flowList)



if __name__ == '__main__':

    # Start up the server to expose the metrics.
    start_http_server(exporter_port)
    #Core loop ; retrieve metrics then wait to poll again.
    while True:
        with Flow("collect-all") as flow:
            getAllMetrics()
        flow.run()
        time.sleep(polling_interval_seconds)
