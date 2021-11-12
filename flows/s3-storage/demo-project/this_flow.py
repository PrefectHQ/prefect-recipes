from prefect import Flow, task
# from prefect.core.task import Parameter
from prefect.storage.s3 import S3

from helpers import custom

# S3 storage

PROJECT = "test-project"

storage = S3(
    bucket = "cs-template-s3-flow-storage",
    key = f"{PROJECT}/this_flow.py",
    stored_as_script = True,
    local_script_path = "this_flow.py",
)


@task(name="General import", log_stdout=True)
def ImportJob(i: object):
    print(i.info)

with Flow(
    name='Import Some Sources',
    storage=storage,

) as flow:
    sources = [custom.MyClass() for i in range(5)]
    ImportJob.map(sources)

if __name__ == "__main__":
    flow.run(run_on_schedule=False)