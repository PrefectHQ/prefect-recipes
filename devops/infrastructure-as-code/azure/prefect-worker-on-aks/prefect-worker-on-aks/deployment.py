import sys
import json

# Prefect 2
from prefect_bitbucket.repository import BitBucketRepository
from prefect.deployments import Deployment


deployment = Deployment(
    name=f"aks-test",
    flow_name=f"transform_flow",
    version="latest",
    work_pool_name="aks-test",
    storage=BitBucketRepository.load("azure-deployment"),
    path="/opt/prefect/flows/",
    entrypoint="prefect-worker-on-aks/transform_flow.py:transform_flow",
)

deployment.apply()
