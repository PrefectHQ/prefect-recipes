import sys
import json

# Prefect 2
from prefect.infrastructure import KubernetesJob
from prefect.deployments import Deployment


deployment = Deployment(
    name=f"az-test",
    flow_name=f"myflow",
    version="latest",
    work_pool_name="aci-test",
    path="/opt/prefect/flows/",
    entrypoint="flow.py:myflow",
)

deployment.apply()
