from os import environ, path
import sys

# Prefect 2
from prefect.deployments import Deployment

# Without a storage block for remote storage, the PATH of the flow, and the ENTRYPOINT are required to locate the flow in docker.
# The flow is at /opt/prefect/flows/flow.py from step 4 when we built the image

# You can store more than one flow in the same container
# Suggested practice would be:
    # copy transform_flow.py /opt/prefect/flows/transform_flow/
    # path="/opt/prefect/flows/transform_flow/"
    # entrypoint="transform_flow.py:transform_flow"

deployment = Deployment(
    name="aci-test",
    version="latest",
    flow_name="transform_flow",
    work_pool_name="aci-test",
    path="/opt/prefect/flows",
    entrypoint="transform_flow.py:transform_flow",
)
deployment.apply()
