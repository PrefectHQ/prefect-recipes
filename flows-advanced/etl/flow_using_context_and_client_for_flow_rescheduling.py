from prefect.client import get_client
from prefect.context import get_run_context
from prefect.orion.schemas.states import Scheduled
from prefect import flow, task, get_run_logger

# -- Build a Subflow to Demonstrate get_run_context() and return_state Argument --
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

    # Now we will raise an artificial error that will prompt us to rescheudle
    # the parent flow x hours in the future
    raise Exception('Deliberate Failure for Example.')


# -- Build a Subflow to Add Scheduled Flow Runs to a Deployment --
@task
async def add_new_scheduled_run(depl_id, original_start_time, delta_hours=6):
    """This task adds a scheduled flow run x hours from the expected start time of the current flow."""
    # Get the time x hours from now.
    scheduled_time = original_start_time.add(hours=delta_hours)

    # Use Prefect get_client() to schedule a new flow run x hours from now
    async with get_client() as client:
        response = await client.create_flow_run_from_deployment(
            deployment_id=depl_id,
            state=Scheduled(scheduled_time=scheduled_time)
        )
    logger = get_run_logger()
    logger.info(f"INFO Scheduled a flow run for {scheduled_time}!")


@flow
def scheduling_flow(depl_id, original_start_time, delta_hours):
    # Running the scheduling task in a subflow since
    # it's use of get_client requires asychrous execution.
    add_new_scheduled_run.submit(depl_id, original_start_time, delta_hours)


@flow
def main_flow():

    # Run the Sub-Flow with return_state=True
    flow_state = flow_that_logs_context(return_state=True)

    # We'll use the state.is_completed method to check the status of the subflow
    logger = get_run_logger()
    logger.info(f"INFO In complete state? {flow_state.is_completed()}")

    # Lets schedule this flow to run in a few hours from now if the subflow failed
    if not flow_state.is_completed():
        # Use Context to Get Deployment ID
        depl_id = get_run_context().flow_run.dict()['deployment_id']

        # Also use Context to get original scheduled start time
        original_start_time = get_run_context().flow_run.dict()['expected_start_time']

        # Schedule Flow to run 6 Hours from Original Flow Scheduled Start Time
        scheduling_flow(depl_id, original_start_time, delta_hours=6)


if __name__ == "__main__":
    main_flow()
