from prefect import Flow, context, task
from prefect.tasks.dbt import DbtShellTask
from prefect.triggers import all_failed, any_successful

# Initialize DbtShellTask for initial dbt build
dbt_build = DbtShellTask(
    name="Build dbt models",
    command="dbt build",
    return_all=True,
    environment="dev",
    profiles_dir=".",
    profile_name="jaffle_shop",
)

# Initialize second DbtShellTask to handle reruning failed models
dbt_rerun_failed_models = DbtShellTask(
    name="Rerun failed dbt models",
    command="dbt build --select result:error+ --defer --state ./target",
    return_all=True,
    environment="dev",
    profiles_dir=".",
    profile_name="jaffle_shop",
    # all_failed trigger ensures this task will only run if the initial DbtShellTask
    # fails
    trigger=all_failed,
)


# Task for illustrative purposes. Important part is the any_successful trigger which
# ensures that this task will run if either the initial dbt build or the rerun is
# successful.
@task(trigger=any_successful)
def final_task():
    logger = context.get("logger")
    logger.info("Flow was successfull!")


with Flow("dbt rerun failed models demo flow") as flow:
    build = dbt_build()
    # Set the upstream tasks on the rerun task to ensure this task triggers of the
    # initial run
    build_rerun = dbt_rerun_failed_models(upstream_tasks=[build])
    # Set both tasks as upstream to ensure that the final task reruns if either of
    # the proceeding tasks are successful.
    final_task(upstream_tasks=[build, build_rerun])

if __name__ == "__main__":
    flow.run()
