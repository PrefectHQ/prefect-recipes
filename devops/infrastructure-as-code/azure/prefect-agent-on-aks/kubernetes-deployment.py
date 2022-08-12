from prefect import flow, get_run_logger
from prefect.deployments import Deployment
from prefect.flow_runners import KubernetesFlowRunner


@flow
def my_kubernetes_flow():
    logger = get_run_logger()
    logger.info("Hello from Kubernetes!")


Deployment(
    name="k8s-example-deployment",
    flow=my_kubernetes_flow,
    flow_runner=KubernetesFlowRunner(),
)
