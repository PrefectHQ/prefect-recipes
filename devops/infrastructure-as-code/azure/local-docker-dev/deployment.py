from os import environ, path
import sys

# Prefect 2
from prefect.deployments import Deployment

from prefect_azure.container_instance import AzureContainerInstanceJob

# Replace with your block name
azure_container_instance_job_block = AzureContainerInstanceJob.load("azure-aci-job")

# Without a storage block for remote storage, the PATH of the flow, and the ENTRYPOINT are required to locate the flow in docker.
# The flow is at /opt/prefect/flows/flow.py from step 4 when we built the image

deployment = Deployment(
    name="aks-test",
    version="latest",
    flow_name="myflow",
    infrastructure=azure_container_instance_job_block,
    work_queue_name="aks-test",
    path="/opt/prefect/flows",
    entrypoint="flow.py:myflow",
)
deployment.apply()
