from prefect import Flow, task, context
from prefect.tasks.dbt import DbtShellTask
from prefect.triggers import all_failed, any_successful


dbt_build = DbtShellTask(
    name="Build dbt models",
    command="dbt build",
    return_all=True,
    environment="dev",
    profiles_dir=".",
    profile_name="jaffle_shop",
)

dbt_rerun_failed_models = DbtShellTask(
    name="Rerun failed dbt models",
    command="dbt build --select result:error+ --defer --state ./target",
    return_all=True,
    environment="dev",
    profiles_dir=".",
    profile_name="jaffle_shop",
    trigger=all_failed,
)


@task(trigger=any_successful)
def final_task():
    logger = context.get("logger")
    logger.info("Flow was successfull!")


with Flow("dbt rerun failed models demo flow") as flow:
    build = dbt_build()
    build_rerun = dbt_rerun_failed_models(upstream_tasks=[build])
    final_task(upstream_tasks=[build, build_rerun])

if __name__ == "__main__":
    flow.run()
