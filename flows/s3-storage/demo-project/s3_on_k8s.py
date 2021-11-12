from prefect import Flow, task
from prefect.core.task import Parameter
from prefect.storage.s3 import S3

# S3 storage

PROJECT = "test-project"

storage = S3(
    bucket = "cs-template-s3-flow-storage",
    key = f"{PROJECT}/my_import_job",
    stored_as_script = True,
    local_script_path = "s3_on_k8s.py",
)


@task(name="General import", log_stdout=True)
def ImportJob(i: str):
    print('do something')

with Flow(
    name='Import Some Sources',
    storage=storage,

) as flow:
    sources = Parameter('sources', default=['']*5)
    ImportJob.map(sources)

if __name__ == "__main__":
    flow.run(run_on_schedule=False)