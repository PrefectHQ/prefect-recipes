from prefect import flow, get_run_logger
from prefect.deployments import Deployment


@flow(name="run")
async def dbt_flow():
    get_run_logger().info("Running DBT job...")


@flow(name="train")
async def model1_flow():
    get_run_logger().info("Running Model 1 training job...")


@flow(name="train")
async def model2_flow():
    get_run_logger().info("Running Model 2 training job...")


@flow(name="train")
async def model3_flow():
    get_run_logger().info("Running Model 3 training job...")


dbt_1 = Deployment.build_from_flow(
    name="dbt",
    flow=dbt_flow,
    tags=[]
).apply()

model_1 = Deployment.build_from_flow(
    name="model-1",
    flow=model1_flow,
    tags=[
        "group:ml",
        "depends_on:run/dbt"
    ]
).apply()

model_2 = Deployment.build_from_flow(
    name="model-2",
    flow=model2_flow,
    tags=[
        "group:ml",
        "depends_on:run/dbt"
    ]
).apply()


model_3 = Deployment.build_from_flow(
    name="model-3",
    flow=model3_flow,
    tags=[
        "group:ml",
        "depends_on:train/model-1",
        "depends_on:train/model-2",
    ]
).apply()
