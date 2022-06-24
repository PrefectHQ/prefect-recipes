from prefect import flow, get_run_logger
from prefect.deployments import DeploymentSpec
from prefect.flow_runners import KubernetesFlowRunner

@flow
def my_kubernetes_flow():
    logger = get_run_logger()
    logger.info("Hello from Kubernetes!")

DeploymentSpec(
    name="k8s-example",
    flow=my_kubernetes_flow,
    flow_runner=KubernetesFlowRunner()
)
