from datetime import datetime, timedelta
from prefect import Flow, task
from prefect.engine.signals import FAIL
from prefect.schedules.schedules import IntervalSchedule
from prefect.tasks.airbyte.airbyte import AirbyteConfigurationExport
from prefect.tasks.secrets import PrefectSecret

import boto3

schedule = IntervalSchedule(interval=timedelta(hours=6))


airbyte_export_task = AirbyteConfigurationExport(airbyte_server_port=8000)

@task
def write_export(bucket: str, export: bytearray) -> None:
    today_str = datetime.now().strftime("%m-%d-%y")
    s3 = boto3.client("s3")
    try:
        s3.put_object(Bucket=bucket, Body=export, Key=f"{filename}_{today_str}.gz")
    except Exception:
        raise FAIL("Could not write export")

with Flow(
    "airbyte_export",
    schedule=schedule,
) as flow:
    
    S3_bucket = "my_s3_bucket"
    filename = "airbyte-config-archive"
    
    export = airbyte_export_task(airbyte_server_host=PrefectSecret("AIRBYTE_HOSTNAME")) 
        
    write_export(S3_bucket, export)
        
if __name__ == "__main__":
    flow.run(run_on_schedule=False)
