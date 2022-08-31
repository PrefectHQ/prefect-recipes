import asyncio
from prefect.client import get_client
from prefect.context import get_run_context
from prefect.orion.schemas.states import Scheduled
from prefect import flow, task, get_run_logger

# -- Build a subflow to demonstrate get_run_context() and return_state argument.
@task
def task_that_gives_context():
    """For this task I will return the run context"""
    print("I am a task.")
    task_run_context_dict = get_run_context().task_run.dict()
    # check out the availble keys
    print(task_run_context_dict.keys())


@flow
def flow_that_gives_context():
    """For this subflow I will call with a `return_state=True` argument"""
    task_that_gives_context(return_state=True)

    flow_run_context_dict = get_run_context().flow_run.dict()
    # check out the availble keys
    print(flow_run_context_dict.keys())

    # Now we will raise an artificial error.
    raise Exception('Deliberate Failure for Example.')


# -- Build a Subflow to Add Scheduled Flow Runs to a Deployment
@task
async def add_new_scheduled_run(depl_id, original_start_time, delta_hours=6): 
    """This task adds a scheduled flow run delta_hours from the expected start time of the current flow."""
    scheduled_time=original_start_time.add(hours=delta_hours)
    async with get_client() as client:
        response = await client.create_flow_run_from_deployment(
            deployment_id=depl_id,
            state=Scheduled(scheduled_time=scheduled_time) 
            )
    print(f'Scheduled a flow run for {scheduled_time}!')

@flow
def scheduling_flow(depl_id, original_start_time):
    """Running the scheduling task in a subflow since it's use of get_client requires asychrous execution."""
    add_new_scheduled_run.submit(depl_id, original_start_time)


@flow
def main_flow():

    flow_state = flow_that_gives_context(return_state=True)
    # check out the availble context keys
    print(flow_state.dict().keys)
    
    # We'll use the state.is_completed method.
    print('In complete state?', flow_state.is_completed())

    if not flow_state.is_completed():
        # Use Context to Get Deployment ID and Scheduled Start Time
        depl_id = get_run_context().flow_run.dict()['deployment_id']

        # Get original scheduled start time from context
        original_start_time = get_run_context().flow_run.dict()['expected_start_time']
        
        # Schedule Flow to run 6 Hours from Original Flow Scheduled Start Time
        scheduling_flow(depl_id, original_start_time, delta_hours=6)



if __name__ == "__main__":
    main_flow()