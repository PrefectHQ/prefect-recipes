from datetime import timedelta

from prefect import Flow, Parameter
from prefect.tasks.airbyte.airbyte import AirbyteConnectionTask
from prefect.tasks.secrets import PrefectSecret

airbyte_sync_task = AirbyteConnectionTask(
    max_retries=3, retry_delay=timedelta(seconds=10)
)

with Flow(
    "airbyte sync",
) as flow:

    airbyte_sync_id = Parameter("airbyte_sync_id", default=None)

    host, port = (PrefectSecret("AIRBYTE_HOSTNAME"), PrefectSecret("AIRBYTE_PORT"))

    airbyte_sync = airbyte_sync_task(
        airbyte_server_host=host,
        airbyte_server_port=port,
        airbyte_api_version="v1",
        connection_id=airbyte_sync_id,
    )

if __name__ == "__main__":
    flow.run(run_on_schedule=False)
