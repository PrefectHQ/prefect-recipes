import asyncio
from typing import Dict, List

import networkx as nx
from prefect import get_client, task, flow
from prefect.deployments import run_deployment
from prefect.logging import get_run_logger
from prefect.server.schemas.filters import DeploymentFilterTags, DeploymentFilter


async def _get_deployments_with_dependencies(filter_tags: DeploymentFilterTags) -> Dict[str, List[str]]:
    """
    Get deployments that match the filter and build a dictionary of {deployment -> list of upstream deployments}
    """
    result = dict()

    async with get_client() as client:
        deployments = await client.read_deployments(
            deployment_filter=DeploymentFilter(
                tags=filter_tags
            )
        )

        for deployment in deployments:
            dependencies = []
            for tag in deployment.tags:
                if not tag.startswith("depends_on:"):
                    continue

                parts = tag.split(":", 2)
                dependencies.append(parts[1])

            deployment_flow = await client.read_flow(deployment.flow_id)
            result[f"{deployment_flow.name}/{deployment.name}"] = dependencies

    return result


async def _construct_nx_graph(deployments: Dict[str, List[str]]) -> nx.DiGraph:
    """
    Constructs a DAG from our dictionary of {deployment -> list of upstream deployments}
    """
    nodes = []
    edges = []

    for node, upstreams in deployments.items():
        nodes.append(node)
        for upstream in upstreams:
            edge = (upstream, node)
            edges.append(edge)

    graph = nx.DiGraph()
    graph.add_nodes_from(nodes)
    graph.add_edges_from(edges)
    return graph


async def run_orchestrator_flow(filter_tags: DeploymentFilterTags) -> None:
    """
    Runs an orchestrator flow by constructing a graph of deployments to execute, where :filter_tags specifies which
    deployments to build the graph from, and using the 'depends_on' tag to specify dependencies between deployments.
    Deployment flows are then executed in topological order, based on these dependencies.
    """
    deployments = await _get_deployments_with_dependencies(filter_tags)

    if len(deployments) == 0:
        get_run_logger().warning("No deployments found for given filter")
        return

    graph = await _construct_nx_graph(deployments)
    futures = dict()

    for deployment_name in nx.topological_sort(graph):
        upstream_deployment_names = list(graph.predecessors(deployment_name))
        upstream_deployment_futures = [futures[t] for t in upstream_deployment_names]
        get_run_logger().info(f"Submitting task {deployment_name}")

        @task(name=deployment_name)
        async def worker_task(name: str):
            get_run_logger().info(f"Running deployment {name}")
            await run_deployment(name)

        futures[deployment_name] = await worker_task.submit(
            name=deployment_name,
            wait_for=upstream_deployment_futures,
        )

@flow(name="orchestration-test-flow")
async def example_flow():
    await run_orchestrator_flow(DeploymentFilterTags(all_=["group:ml"]))

asyncio.run(example_flow())
