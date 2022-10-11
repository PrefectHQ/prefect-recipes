""" Prefect Recipes

A orchestrator-worker pattern using the `OrionClient` to call create_flow_run_from_deployment. # noqa
Assumes you have a `String` block named "my-worker-deployment-id".
Ideal for distributing work at large scales across worker flows.

"""

import asyncio
from random import randint
from typing import Dict, Iterable, List, Mapping, Union

from prefect import flow, get_run_logger, task, unmapped
from prefect.blocks.system import String
from prefect.client import get_client
from prefect.context import FlowRunContext
from prefect.exceptions import ObjectNotFound, PrefectHTTPStatusError
from prefect.orion.schemas.core import FlowRun
from prefect.orion.schemas.filters import FlowFilterTags, FlowRunFilter


@flow
def worker_flow(
    worker_parameter_chunk: Union[str, int, float, Mapping, Iterable], **kwargs
):
    """A worker flow to be kicked off by the orchestrator flow

    just showing for reference, this flow could be deployed already and
    then referenced by its deployment ID in the orchestrator flow as shown below

    Args:
    - worker_parameter_chunk: some JSON serializable chunk of parameters
        passed from the orchestrator flow to process here in the worker
    """
    params = locals()
    logger = get_run_logger()

    logger.info(f"Look at these parameters I got from my parent!: {params}")

    logger.info("Goodbye!")


"""
Lets say we want to dynamically create many instances
    of this flow with different parameters


Let's see how we can create an orchestrator flow that
    will do just this!
"""


def summarize(status: Dict[str, List[FlowRun]]) -> str:
    """Utility function to cleanly log the number of flows in each state.
    Args:
        status (Dict): keys are state names, associated values
            are flow run models in that state
    Returns:
        str: pretty print summary of flow run states
    """
    return " | ".join(f"{k}: {len(v)}" for k, v in status.items())


@task
def build_chunked_subflow_params(chunk: Dict, static_params: Dict) -> Dict:
    """Build an iterable that we can easily map `submit_subflows` over
    Args:
        chunk (Dict): Dict representation of `chunk_size` records to be passed to
            a given subflow
        static_params (Dict): kwargs that will be consistent among subflow runs
    Returns:
        Dict: Everything an instance of `worker` flow needs to run
    """
    # replace with your own logic to build the chunked parameters

    return {"worker_parameter_chunk": chunk, **static_params}


@task(name="Invoke a single `worker` flow")
async def submit_subflow(params: Dict, deployment_id: str, tags: Iterable[str]):
    """Async task to create a flow run from a deployment
    Args:
        deployment_id (str): Prefect Deployment ID of a flow deployment
        params (Dict): the parameters an instance of the subflow needs to run
        tags (Iterable[str]): tags to apply to the worker flow runs
    """
    logger = get_run_logger()
    try:
        async with get_client() as client:
            flow_run_model = await client.create_flow_run_from_deployment(
                parameters=params, deployment_id=deployment_id, tags=tags
            )
            logger.info(f"Created flow run {flow_run_model.name}!")
    except (PrefectHTTPStatusError, ObjectNotFound) as err:
        logger.error(f"{err!r}")
        raise


@task(name="Poll for subflow status")
async def poll_for_subflow_completion(
    filter: FlowRunFilter, POLL_INTERVAL_S: int = 20
) -> Dict:
    """Task for monitoring state of worker flow runs and raising their failures
    Args:
        filter (FlowRunFilter): Prefect Orion database filter for
            retrieving worker flow runs.
        POLL_INTERVAL_S (int, optional): how often to poll for `subflow_status`.
    Raises:
        ValueError: if no worker flow runs match `FlowRunFilter` criteria
    Returns:
        Dict: summary of worker flow run states
    """
    logger = get_run_logger()

    async with get_client() as client:
        while True:
            subflow_status = {}
            subflows = await client.read_flow_runs(flow_run_filter=filter)

            for subflow in subflows:
                subflow_status.setdefault(subflow.state.name, []).append(subflow)

            if not subflow_status:
                raise ValueError("No subflows matching flow run filter!")

            if "Failed" in subflow_status:
                message = (
                    "The following worker flow runs finished in state Failed: "
                    f"{[run.name for run in subflow_status['Failed']]}"
                )
                logger.warning(message)

            if "Crashed" in subflow_status:
                message = (
                    "The following worker flow runs finished in state Crashed: "
                    f"{[run.name for run in subflow_status['Crashed']]}"
                )
                logger.warning(message)

            logger.info(summarize(subflow_status))

            if not any(
                state in subflow_status for state in ["Pending", "Scheduled", "Running"]
            ):
                return subflow_status

            await asyncio.sleep(POLL_INTERVAL_S)


@flow(name="My Orchestrator Flow")
def orchestrator(worker_deployment_id_block_name: str, chunk_size: int = 2):
    """Orchestrator flow to kick off instances of worker subflows

    You could also pass in:
    - name of a `String` block holding a SQL query / filepath / http request info
        to fetch data to pass to worker flows
    - the name of a Slack Webhook block to refer to surfacing errors in the worker flows
    - additional filter criteria to use while polling worker flow run states

    Args:
        worker_deployment_id_block_name (str): name of a Prefect Deployment block
            which holds your worker deployment ID
        chunk_size (int, optional): The number of records to distribute
            to a given worker subflow
    """
    logger = get_run_logger()

    # get current flow run name
    flow_context = FlowRunContext.get()
    flow_run_name = flow_context.flow_run.name
    TAGS = [flow_run_name]

    # replace with results of some SQL query or other data source fetch
    n_input_records = randint(10, 20)  # doesn't matter how many records we have!

    data_to_distrbute_across_subflows = [
        {"a": 1, "b": 2} for _ in range(n_input_records)
    ]

    # chunk data according to `chunk_size` to distribute across subflows
    chunked_subflow_data = [
        data_to_distrbute_across_subflows[i : i + chunk_size]  # noqa
        for i in range(0, len(data_to_distrbute_across_subflows), chunk_size)
    ]

    logger.info(
        f"Chunked data into {len(chunked_subflow_data)} chunks"
        f" to be distributed to {len(chunked_subflow_data)} subflows!"
    )

    # assemble nice args for `submit_subflows` to map over
    static_subflow_params = dict(  # static as in, each is passed to every subflow
        parent_flow_name=flow_run_name,
        whos_that_pokemon="Pikachu",
        whos_that_blue_duck="Marvin",
        answer_to_it_all=42,
    )
    subflow_param_chunks = build_chunked_subflow_params.map(
        chunk=chunked_subflow_data, static_params=unmapped(static_subflow_params)
    )

    # distribute chunks of rows over subflows
    WORKER_DEPLOYMENT_ID = String.load(worker_deployment_id_block_name).value

    submitted = submit_subflow.map(
        params=subflow_param_chunks,
        deployment_id=unmapped(WORKER_DEPLOYMENT_ID),
        tags=unmapped(TAGS),
    )

    # make bool return values resolve before checking if `submitted`
    if all([i.result() for i in submitted]):

        worker_flow_run_filter = FlowRunFilter(tags=FlowFilterTags(all_=TAGS))

        poll_for_subflow_completion(filter=worker_flow_run_filter)


if __name__ == "__main__":
    orchestrator(
        worker_deployment_id_block_name="my-worker-deployment-id",
    )
