import asyncio

from chalice import Chalice
from prefect import flow, get_client, get_run_logger

app = Chalice(app_name="serverless-aws-chalice")


@flow
def hello_from_chalice(name: str):
    """Simple Prefect flow that logs a greeting"""
    get_run_logger().info(f"Hello from Chalice, {name}!")


async def _read_deployment(deployment_id: str):
    """Helper async function to read a deployment"""
    async with get_client() as client:
        resp = await client.read_deployment(deployment_id)
        return resp.json()


async def _create_flow_run(deployment_id: str):
    """Helper async function to create a flow run"""
    async with get_client() as client:
        resp = await client.create_flow_run_from_deployment(deployment_id)
        return resp.json()


@app.route("/hello/{name}")
def index(name: str):
    """Chalice entrypoint for running a flow in process"""
    hello_from_chalice(name)
    return {"message": "success"}


@app.route("/deployment/{deployment_id}")
def read_deployment(deployment_id: str):
    """Chalice entrypoint for reading a deployment"""
    deployment = asyncio.run(_read_deployment(deployment_id))
    return deployment


@app.route("/deployment/{deployment_id}/run", methods=["POST"])
def read_deployment(deployment_id: str):
    """Chalice entrypoint for creating a flow run"""
    flow_run = asyncio.run(_create_flow_run(deployment_id))
    return flow_run
