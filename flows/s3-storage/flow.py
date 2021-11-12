from prefect import Flow, task
from prefect.storage.s3 import S3

FLOW_ID = 'S3 Storage Demo'

storage = S3(
    bucket = "tps-prefect-flows",
    key = FLOW_ID,
    stored_as_script = True,
    local_script_path = "flow.py"
)

with Flow(
    name = FLOW_ID,
    storage = storage

) as flow:
    pass

