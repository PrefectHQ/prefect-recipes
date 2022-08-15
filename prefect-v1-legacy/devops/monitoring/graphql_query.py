from python_graphql_client import GraphqlClient
import os
import asyncio

default_endpoint = "http://127.0.0.1:4200"
GRAPHQL_ENDPOINT = os.environ.get("GRAPHQL_ENDPOINT", default_endpoint)


def query_Projects():
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

    r = asyncio.run(client.execute_async(query=query))
    print(r)


# Requires project_id passed in
def queryFlowsByProject(project_id: str) -> list:

    variables = {"projectId": project_id}

    flow_by_project_query = """
        query Flows ($projectId: uuid!){
        flow (where: {project_id: {_eq: $projectId}}) {
            id,
            flow_group_id,
            name,
            project_id,
            is_schedule_active
            }
        }
    """
    client = GraphqlClient(endpoint=GRAPHQL_ENDPOINT)

    r = asyncio.run(
        client.execute_async(query=flow_by_project_query, variables=variables)
    )
    print(r)


project_ID = ""
query_Projects()
queryFlowsByProject(project_ID)
