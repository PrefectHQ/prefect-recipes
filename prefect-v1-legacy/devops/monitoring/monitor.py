from prometheus_client import start_http_server, Gauge, Counter
import time
from datetime import datetime
import os
import asyncio
import logging
import sys
from python_graphql_client import GraphqlClient



#
TIME_FORMAT_LATE = "%Y-%m-%dT%H:%M:%S.%f+00:00"
# Project Variables
projectNumber = Gauge("project_number", "Total count of all Prefect Projects")
projectTotal = Gauge("prefect_projects", "Number of Projects by Name", ["name"])

# Flow Variables
flowTotal = Gauge("prefect_flows", "Total of All Flows, All Projects")
flowProjectTotal = Gauge(
    "prefect_flows_by_project",
    "Number of Flows by Project Name",
    ["project_id", "project_name"],
)
flowRunTotal = Gauge(
    "prefect_flowruns_total",
    "Number of total flow runs by flow ID",
    ["project_id", "project_name"],
)
flowRunTotalSuccess = Gauge(
    "prefect_flowruns_success",
    "Number of successful flow runs by Project",
    ["project_id", "project_name"],
)
flowRunPending = Gauge(
    "prefect_flowruns_pending",
    "Number of pending flow runs by Project",
    ["project_id", "project_name"],
)
flowRunLate = Gauge(
    "prefect_flowruns_late",
    "Number of late flow runs by Project",
    ["project_id", "project_name"],
)
flowRunFailed = Gauge(
    "prefect_flowruns_failed",
    "Number of Failed flow runs by Project",
    ["project_id", "project_name"],
)
flowRunRunning = Gauge(
    "prefect_flowruns_running",
    "Number of running flow runs by Project",
    ["project_id", "project_name"],
)
flowRunUpcoming = Gauge(
    "prefect_flowruns_upcoming",
    "Number of Upcoming flow runs by Project",
    ["project_id", "project_name"],
)
flowRunQueued = Gauge(
    "prefect_flowruns_queued",
    "Number of queued flow runs by Project",
    ["project_id", "project_name"],
)
flowRunSubmitted = Gauge(
    "prefect_flowruns_submitted",
    "Number of submitted flow runs by Project",
    ["project_id", "project_name"],
)
queries_total = Counter(
    "prefect_graphql_queries", "Number of queries submitted to GraphQL for monitoring"
)
# Main loop retrieves exports all metrics
# Each export queries GraphQL, extracts relevant info, and exports to a metrics


def getAllMetrics():
    allProjects = queryAllProjects()
    # exportAllProjects(allProjects)
    # exportAllFlows()
    # exportFlowsByProject(allProjects)
    # exportFlowRunTotal(allProjects)
    # exportFlowRunSuccess(allProjects)
    # exportFlowStatus(allProjects)
    exportflowRunUpcoming(allProjects)
    exportflowRunRunning(allProjects)


def callQuery(query: str, queryName: str, variables: dict = None) -> object:
    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)
    success = False
    counter = 0
    while not success and counter < MAX_RETRY:
        try:
            tic = time.time()
            r = asyncio.run(client.execute_async(query=query, variables=variables))
            toc = time.time()
            queries_total.inc()
            success = True
            if variables is None:
                logging.info(f"{queryName} took {toc - tic}")
            else:
                logging.info(
                    f"{queryName} - {variables['project_id']} - took {toc - tic}"
                )
        except (ConnectionResetError, TimeoutError) as err:
            if counter >= MAX_RETRY:
                logging.warning(f"Max attempts exceeded. {err}")
                raise
            counter += 1
            logging.warning(f"{err} - Retrying connection. Attempt {counter}")
            time.sleep(TIME_BETWEEN_RETRY)
        except Exception as e:
            logging.warning(repr(e))
            raise
    return r


# Queries GraphQL for all projects.
# Query returns a json object, which is passed to listify.
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
    queryName = "queryAllProjects"
    projectList = callQuery(query, queryName)
    return projectList["data"]["project"]


def queryAllFlows() -> int:
    query = """
        query Flows {
            flow (where: {archived: {_eq: false}}){
                id,
                flow_group_id,
                name,
                project_id,
                is_schedule_active
            }
        }
    """

    queryName = "queryAllFlows"
    r = callQuery(query, queryName)
    return len(r["data"]["flow"])

#Late flows are derived from "Scheduled" flow runs that are at least 30 seconds old.

def queryUpcomingFlowRuns(project_id: str) -> list:
    variables = {"project_id": project_id}

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

    queryName = "queryUpcomingFlowRuns"
    flowRunsUpcoming = callQuery(query, queryName, variables)
    return flowRunsUpcoming["data"]["flow_run"]

def lateFlowRuns(flow_runs: list) -> int:

    #scheduled_start_time = "2022-03-26T18:57:28.933746+00:00"
    time_now = datetime.now()
    late_flows = 0
    print (flow_runs)
    try:
        for run in flow_runs["data"]["flow_run"]:
            run_time = run['scheduled_start_time']
            time_dif = time_now - datetime.strptime(run_time, TIME_FORMAT_LATE)
            if time_dif.total_seconds() > 30:
                late_flows += 1
                print (f"{run['name']} is late by {time_dif.total_seconds()} seconds")
    except Exception as e:
        print (repr(e))
    return late_flows


def queryRunningFlowRuns(project_id: str) -> list:
    variables = {"project_id": project_id}

    query = """
    query UpcomingFlowRuns($project_id: uuid) {
        flow_run(
        where: {flow: {project_id: {_eq: $project_id}}, state: {_eq: "Running"}}
        order_by: {scheduled_start_time: asc})
        {
            id
            name
            state
            scheduled_start_time
        }
    }
    """

    queryName = "queryRunningFlowRuns"
    flowRunsRunning = callQuery(query, queryName, variables)
    return len(flowRunsRunning["data"]["flow_run"])


# Returns all active flows in the listed project_id
def queryFlowsByProject(project_id: str) -> list:
    variables = {"project_id": project_id}

    query = """
        query Flows ($project_id: uuid!){
        flow (where:
            { _and: [
                {project_id: {_eq: $project_id}},
                {archived: {_eq: false}} ]
            })
            {
            id
            flow_group_id,
            name,
            project_id,
            is_schedule_active
            }
        }
    """

    queryName = "queryFlowsByProject"
    projectFlows = callQuery(query, queryName, variables)
    return projectFlows["data"]["flow"]


def queryFlowRunTotalByProject(project_id: str) -> list:
    variables = {"project_id": project_id}

    query = """
    query TotalFlowRuns($project_id: uuid) {
        flow_run(where: {flow: {project_id: {_eq: $project_id}}}) {
            id,
            name,
            state
        }
    }
    """

    queryName = "queryFlowRunTotalByProject"
    flowRuns = callQuery(query, queryName, variables)
    return flowRuns["data"]["flow_run"]


def queryFlowRunSuccessByProject(project_id: str) -> list:
    variables = {"project_id": project_id}

    query = """
    query TotalFlowRuns($project_id: uuid) {
        flow_run(where: {flow: {project_id: {_eq: $project_id}},
            state: {_eq: "Success"}}) {
                id,
                name,
                state
            }
    }
    """

    queryName = "queryFlowRunSuccessByProject"
    flowRuns = callQuery(query, queryName, variables)
    return flowRuns["data"]["flow_run"]


def querystatusByProject(project_id: str) -> list:
    variables = {"project_id": project_id}

    query = """
    query FlowRuns($project_id: uuid, $heartbeat: timestamptz) {
        Pending: flow_run_aggregate(where: {
            flow: {project_id: {_eq: $project_id}}, state: {_eq: "Pending"}})
        {
            aggregate {
                count
            __typename
            }
            __typename
        }
        Failed: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}},
            scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Failed"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
        Submitted: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}},
            scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Submitted"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
        Queued: flow_run_aggregate(
            where: {flow: {project_id: {_eq: $project_id}},
            scheduled_start_time: {_gte: $heartbeat}, state: {_eq: "Queued"}}
        ) {
            aggregate {
            count
            __typename
            }
            __typename
        }
    }
    """

    queryName = "querystatusByProject"
    r = callQuery(query, queryName, variables)

    return r


# Updates projectTotal metrics with the label and value of each project queried
def exportAllProjects(allProjects):
    for project in allProjects:
        projectTotal.labels(project["name"]).set(1)
    projectNumber.set(len(allProjects))


# Sets and exports all flow totals across all projects
def exportAllFlows():
    flowTotal.set(queryAllFlows())


# Updates projectTotal metrics with the label and value of each project queried
def exportFlowsByProject(allProjects):
    for project in allProjects:
        project_Flows = queryFlowsByProject(project["id"])
        flowProjectTotal.labels(project["id"], project["name"]).set(len(project_Flows))


def exportFlowRunTotal(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunTotalByProject(project["id"])
        flowRunTotal.labels(project["id"], project["name"]).set(len(project_Flows))


def exportFlowRunSuccess(allProjects):
    for project in allProjects:
        project_Flows = queryFlowRunSuccessByProject(project["id"])
        flowRunTotalSuccess.labels(project["id"], project["name"]).set(
            len(project_Flows)
        )


def exportFlowStatus(allProjects):
    for project in allProjects:
        r = querystatusByProject(project["id"])
        flowRunPending.labels(project["id"], project["name"]).set(
            r["data"]["Pending"]["aggregate"]["count"]
        )
        flowRunFailed.labels(project["id"], project["name"]).set(
            r["data"]["Failed"]["aggregate"]["count"]
        )
        flowRunQueued.labels(project["id"], project["name"]).set(
            r["data"]["Queued"]["aggregate"]["count"]
        )
        flowRunSubmitted.labels(project["id"], project["name"]).set(
            r["data"]["Submitted"]["aggregate"]["count"]
        )


def exportflowRunUpcoming(allProjects):
    for project in allProjects:
        project_Flows = queryUpcomingFlowRuns(project["id"])
        if project_Flows:
            late_flows = lateFlowRuns(project_Flows)
        else:
            print (f"No flows are scheduled or late for {project['name']}.")
            late_flows = 0
        flowRunUpcoming.labels(project["id"], project["name"]).set(len(project_Flows))
        flowRunLate.labels(project["id"], project["name"]).set(late_flows)


def exportflowRunRunning(allProjects):
    for project in allProjects:
        project_Flows = queryRunningFlowRuns(project["id"])
        flowRunRunning.labels(project["id"], project["name"]).set(project_Flows)


if __name__ == "__main__":

    POLLING_INTERVAL = int(os.environ.get("POLLING_INTERVAL", 300))
    EXPORT_PORT = int(os.environ.get("EXPORT_PORT", 8000))
    GRAPHQL_ENDPOINT = os.environ.get("GRAPHQL_ENDPOINT", "http://127.0.0.1:4200")
    MAX_RETRY = 3
    TIME_BETWEEN_RETRY = 60
    logFormat = "%(asctime)s - %(message)s"
    logging.basicConfig(format=logFormat, stream=sys.stderr, level=logging.INFO)
    logger = logging.getLogger("prefect")
    # Start up the server to expose the metrics.
    start_http_server(EXPORT_PORT)

    # Core loop ; retrieve metrics then wait to poll again.
    while True:
        tic_main = time.time()
        logger.info("Getting all metrics.")
        getAllMetrics()
        toc_main = time.time()
        logger.info("All metrics received.")
        logger.info(f"Time Elapsed - {toc_main - tic_main}")
        logger.info(f"Sleeping for {POLLING_INTERVAL}.")
        time.sleep(POLLING_INTERVAL)
