from prometheus_client import start_http_server, Gauge, Counter
import time
import os
import asyncio
import logging
import sys
from python_graphql_client import GraphqlClient


# Project Variables
projectNumber = Gauge('project_number', 'Total count of all Prefect Projects')
projectTotal = Gauge('prefect_projects', 'Number of Projects by Name',['name'])

# Flow Variables
flowTotal = Gauge('prefect_flows', 'Total of All Flows, All Projects')
flowProjectTotal = Gauge('prefect_flows_by_project', 'Number of Flows by Project Name',['project_id', 'project_name'])
flowRunTotal = Gauge('prefect_flowruns_total', 'Number of total flow runs by flow ID', ['project_id', 'project_name'])
flowRunTotalSuccess = Gauge('prefect_flowruns_success', 'Number of successful flow runs by Project', ['project_id', 'project_name'])
flowRunPending = Gauge('prefect_flowruns_pending', 'Number of pending flow runs by Project', ['project_id', 'project_name'])
flowRunFailed = Gauge('prefect_flowruns_failed', 'Number of Failed flow runs by Project', ['project_id', 'project_name'])
flowRunRunning = Gauge('prefect_flowruns_running', 'Number of running flow runs by Project', ['project_id', 'project_name'])
flowRunUpcoming = Gauge('prefect_flowruns_upcoming', 'Number of Upcoming flow runs by Project', ['project_id', 'project_name'])
flowRunQueued = Gauge('prefect_flowruns_queued', 'Number of queued flow runs by Project', ['project_id', 'project_name'])
flowRunSubmitted = Gauge('prefect_flowruns_submitted', 'Number of submitted flow runs by Project', ['project_id', 'project_name'])
queries_total = Counter('prefect_graphql_queries', 'Number of queries submitted to GraphQL for monitoring')
# Main loop retrieves exports all metrics
# Each export queries GraphQL, extracts relevant info, and exports to a metrics

def getAllMetrics():
    allProjects = queryAllProjects()
    exportAllProjects(allProjects)
    exportAllFlows()
    exportFlowsByProject(allProjects)
    exportFlowRunTotal(allProjects)
    exportFlowRunSuccess(allProjects)
    exportFlowStatus(allProjects)
    exportflowRunUpcoming(allProjects)


# Queries GraphQL for all projects. Query returns a json object, which is passed to listify.

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
    
    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            projectList = asyncio.run(client.execute_async(query=query))
            toc = time.time()
            logging.info(f"queryAllProjects took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)           
        except Exception as e:
            logging.warning(repr(e))
            raise
    return projectList['data']['project']


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

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            r = asyncio.run(client.execute_async(query=query))
            toc = time.time()
            logging.info(f"queryAllFlows - took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)  
        except Exception as e:
            logging.warning(repr(e))
            raise
    return len(r['data']['flow'])

def queryUpcomingFlowRuns(project_id: str) -> list: 
    flowRunsUpcoming = []

    variables = {
        "project_id": project_id
    }

    query = """
    query UpcomingFlowRuns($project_id: uuid) {
        flow_run(
        where: {flow: {project_id: {_eq: $project_id}}, state: {_eq: "Scheduled"}}
        order_by: {scheduled_start_time: asc})
        {
            id
            name
            state
            scheduled_start_time
        }
    }
    """

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            flowRunsUpcoming = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            logging.info(f"queryUpcomingFlowRuns - {project_id} - took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)   
        except KeyError:
            return flowRunsUpcoming['data']['flow_run']
        except Exception as e:
            logging.warning(repr(e))
            raise
    return flowRunsUpcoming['data']['flow_run']

# Returns all active flows in the listed project_id
def queryFlowsByProject(project_id: str) -> list: 

    variables = {
        "project_id": project_id
    }

    query = """
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

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            projectFlows = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            logging.info(f"queryFlowsByProject - {project_id} - took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)  
    return projectFlows['data']['flow']


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

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            flowRuns = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            logging.info(f"queryFlowRunTotalByProject - {project_id} - took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)  
    return flowRuns['data']['flow_run']



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

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            flowRuns = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            logging.info(f"queryFlowRunSuccessByProject - {project_id} - took {toc - tic}")
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)  
    return flowRuns['data']['flow_run']


def querystatusByProject(project_id: str) -> list:
    variables = {
        "project_id": project_id
    }

    query = """
    query FlowRuns($project_id: uuid, $heartbeat: timestamptz) {
        Pending: flow_run_aggregate(where: {flow: {project_id: {_eq: $project_id}}, state: {_eq: "Pending"}}) 
        {
            aggregate {
                count
            __typename
            }
            __typename
        }
        Failed: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}}, scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Failed"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
        Submitted: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}}, scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Submitted"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
        Queued: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}}, scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Queued"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
    }
    """

    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            r = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            logging.info(f"querystatusByProject - {project_id} - took {toc - tic}")
            pendingRuns = (r['data']['Pending']['aggregate']['count'])
            failedRuns = (r['data']['Failed']['aggregate']['count'])
            submittedRuns = (r['data']['Submitted']['aggregate']['count'])
            queuedRuns = (r['data']['Queued']['aggregate']['count'])
            queries_total.inc()
            success = True
        except ConnectionResetError as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"Connection Reset Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)    
        except TimeoutError as timeout:
            if counter > MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {timeout}")
                raise
            counter += 1
            logging.warning(f"Timeout Error. Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)  
    return pendingRuns,failedRuns,submittedRuns,queuedRuns


# Updates projectTotal metrics with the label and value of each project queried
def exportAllProjects(allProjects):
    for project in allProjects:
        projectTotal.labels(project['name']).set(1)
    projectNumber.set(len(allProjects)) 


# Sets and exports all flow totals across all projects
def exportAllFlows():
    flowTotal.set(queryAllFlows())

#Updates projectTotal metrics with the label and value of each project queried
def exportFlowsByProject(allProjects):
    for project in allProjects:
        project_Flows = queryFlowsByProject(project['id'])
        flowProjectTotal.labels(project['id'], project['name']).set(len(project_Flows))

def exportFlowRunTotal(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunTotalByProject(project['id'])
        flowRunTotal.labels(project['id'], project['name']).set(len(project_Flows))

def exportFlowRunSuccess(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunSuccessByProject(project['id'])
        flowRunTotalSuccess.labels(project['id'], project['name']).set(len(project_Flows))

def exportFlowStatus(allProjects):
    for project in allProjects:
        projectFlowPending, projectFlowFailed, projectFlowSubmitted, projectFlowQueued = querystatusByProject(project['id'])
        flowRunPending.labels(project['id'], project['name']).set(projectFlowPending)
        flowRunFailed.labels(project['id'], project['name']).set(projectFlowFailed)
        flowRunQueued.labels(project['id'], project['name']).set(projectFlowSubmitted)
        flowRunSubmitted.labels(project['id'], project['name']).set(projectFlowQueued)


def exportflowRunUpcoming(allProjects):
    for project in allProjects:
        project_Flows = queryUpcomingFlowRuns(project['id'])
        flowRunUpcoming.labels(project['id'], project['name']).set(len(project_Flows))


if __name__ == '__main__':

    POLLING_INTERVAL = int(os.environ.get('POLLING_INTERVAL', 30))
    EXPORT_PORT = int(os.environ.get('EXPORT_PORT', 8000))
    GRAPHQL_ENDPOINT = os.environ.get('GRAPHQL_ENDPOINT', "http://127.0.0.1:4200")
    MAX_RETRY = 3
    TIME_BETWEEN_RETRY = 60
    logFormat='%(asctime)s - %(message)s'
    logging.basicConfig(format=logFormat, stream=sys.stderr, level=logging.INFO)
    logger = logging.getLogger("prefect")
    # Start up the server to expose the metrics.
    start_http_server(EXPORT_PORT)

    #Core loop ; retrieve metrics then wait to poll again.
    while True:
        tic_main = time.time()
        logger.info("Getting all metrics.")
        getAllMetrics()
        toc_main = time.time()
        logger.info("All metrics received.")
        logger.info(f"Time Elapsed - {toc_main - tic_main}")
        logger.info(f"Sleeping for {POLLING_INTERVAL}.")
        time.sleep(POLLING_INTERVAL)
