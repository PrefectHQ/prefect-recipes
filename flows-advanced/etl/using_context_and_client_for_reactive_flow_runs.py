from prefect import flow, get_run_logger, task
from prefect.client import get_client
from prefect.context import get_run_context
from prefect.orion.schemas.states import Scheduled

"""
Line 85 needs to be updated with the relevant deployment ID
"""

# -- Build a Subflow to demonstrate get_run_context() and return_state argument --


@task
def task_that_logs_context():

    task_run_context_dict = get_run_context().task_run.dict()

    # check out the availble keys
    logger = get_run_logger()
    logger.info("INFO I am a task, check out my task run context below:")
    logger.info(f"INFO Task Run Keys: {task_run_context_dict.keys()}")

    # Provide a return value to for .result() example
    return "Hello Result"


@flow
def flow_that_logs_context():

    # Run task with return_state=True to get a Prefect State returned
    task_state = task_that_logs_context(return_state=True)

    # To get the actual value of the tasks output from a Prefect state,
    # use the .result() method
    task_result = task_state.result()
    logger = get_run_logger()
    logger.info(f"INFO Task Result: {task_result}")

    # The availble keys for flow run context work like the task run context.
    flow_run_context_dict = get_run_context().flow_run.dict()

    logger.info("INFO I am a flow, check out my flow run context below:")
    logger.info(f"INFO Flow Run Keys: {flow_run_context_dict.keys()}")

    # Now we will raise an artificial error that will prompt us to schedule
    # a different 'reactive' flow x minutes in the future
    raise Exception("Deliberate Failure for Example.")


# -- Build a Task that adds a schedule for a reactive flow to run --
@task
async def add_new_scheduled_run(depl_id, original_start_time, delta_minutes=0):
    """
    This task adds a scheduled flow run to the deployment of a reactive flow
    x minutes from the start time of the currently executing flow.
    """
    # Get the time x minutes from now.
    scheduled_time = original_start_time.add(minutes=delta_minutes)

    # Use Prefect get_client() to schedule a new flow run x minutes from now
    async with get_client() as client:
        # Pro Tip: create_flow_run_from_deployment has MANY useful argument in addition
        # to adding a schedule, you can also add specific flow parameter values, etc.
        response = await client.create_flow_run_from_deployment(
            deployment_id=depl_id, state=Scheduled(scheduled_time=scheduled_time)
        )
    logger = get_run_logger()
    logger.info(f"INFO get client response: {response}")
    logger.info(f"INFO Scheduled a flow run for {scheduled_time}!")


# -- Build a flow that dynamically schedules a reactive flow upon subflow failure --
@flow
def main_flow():

    # Run the Sub-Flow with return_state=True
    flow_state = flow_that_logs_context(return_state=True)

    # We'll use the state.is_completed method to check the status of the subflow
    logger = get_run_logger()
    logger.info(f"INFO In complete state? {flow_state.is_completed()}")

    # Lets schedule a different reactive flow to run in a few minutes
    # from now if the subflow failed
    if not flow_state.is_completed():
        # Specify Deployment ID for Reactive Flow
        depl_id = "flow-run-id-goes-here-4242"

        # Use Context to get original scheduled start time of current flow.
        original_start_time = get_run_context().flow_run.expected_start_time

        # Schedule Reactive Flow to run 5 Minutes from
        # Current Flow's Scheduled Start Time
        add_new_scheduled_run.submit(depl_id, original_start_time, delta_minutes=5)


if __name__ == "__main__":
    main_flow()
