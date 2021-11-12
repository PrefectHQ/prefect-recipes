from prefect import Flow, task
from prefect.backend import get_key_value
from prefect.core.task import Parameter
from prefect.run_configs import KubernetesRun
from prefect.storage.s3 import S3

# K8s exec
# S3 storage

storage = S3(
    bucket = "prefect-flow-bucket",
    key = "my_import_job",
    stored_as_script = True,
    local_script_path = "s3_on_k8s.py",
)

run_config = KubernetesRun(
    image=get_key_value("TPS_BASE_IMAGE_TEST") # need to define as tenant kv pair
)

@task(name="General import", log_stdout=True)
def ImportJob(i: str):
    print('do something')

with Flow(
    name='Import Some Sources',
    run_config=run_config,
    storage=storage,

) as flow:
    sources = Parameter('sources', default=['']*5)
    ImportJob.map(sources)

if __name__ == "__main__":
    flow.run(run_on_schedule=False)