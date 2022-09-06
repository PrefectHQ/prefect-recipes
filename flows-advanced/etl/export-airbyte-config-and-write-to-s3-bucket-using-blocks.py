"""
Assumes you have:
- a Secret block named `airbyte-hostname-dev` (this is just 'localhost')
- a Secret block named `airbyte-hostname-prod`
- an AwsCredentials block named `prefect-aws-credentials` with the following layout:
{
    "aws_access_key_id": "my-access-key-id",
    "aws_secret_access_key": "my-secret-access-key"
}
- an S3Bucket block named `my-airbyte-config-s3bucket` with the following layout:
{
    "bucket_name"="my-bucket",
    "aws_credentials"=AwsCredentials block,
}

If you are unable to create these blocks in the UI because S3Bucket or AwsCredentials block types do not exist,
run 
`prefect block register -m prefect_aws.credentials`
`prefect block register -m prefect_aws.s3`
to register them in your workspace.

Schedule:
Set to run every 12 hours.
"""

from datetime import datetime
from prefect import flow, task
from prefect.blocks.core import Block
from prefect.blocks.system import Secret
from prefect.deployments import Deployment
from prefect.filesystems import S3
from prefect.infrastructure import KubernetesJob
from prefect.logging import get_run_logger
from prefect_aws import s3
from prefect_airbyte.configuration import export_configuration


@task
async def write_export(
    export: bytearray,
    bucket_block: Block, 
    filename: str 
) -> None:

    """
    Task that writes to an S3 bucket and asserts that the file was loaded.

    Parameters
    ----------
    export: bytearray
       The expected contents to be uploaded.
    bucket_block: Block
        An S3Bucket block storing config about where to load the file.
    filename: str
        A filename prefix (without date attached), e.g. "airbyte-config-archive".
    """

    logger = get_run_logger()
    today_str = datetime.now().strftime("%m-%d-%y")

    try:
        # returns the key, e.g. "airbyte-config-archive_08-29-22.gz"
        key = await bucket_block.write_path(
            path=f"{filename}_{today_str}.gz", 
            content=export
            )

        # use the key to ensure file was loaded
        await bucket_block.read_path(path=key)
        logger.info(f"{key} successfully loaded")

    except Exception as e:
        logger.error(f"Could not write export, {e}")
        raise


@flow
def airbyte_export(
    env: str,
    s3bucket_block_nm: str = "airbyte-config-s3bucket", 
    filename: str = "airbyte-config-archive"
    ) -> None:

    """
    Flow that exports config for Airbyte instance, then write it to an S3 bucket.

    Parameters
    ----------
    env: str
        This is used as the suffix of the secret Airbyte Hostname. Choose
        `dev` or `prod` to use either the `airbyte-hostname-dev` or
        `airbyte-hostname-prod` block.
    bucket_block: Block
        An S3Bucket block storing config about where to load the file.
    filename: str
        A filename prefix (without date attached), e.g. "airbyte-config-archive".
    """

    hostname_secret = Secret.load(f"airbyte-hostname-{env}")
    s3_bucket_block = s3.S3Bucket.load(s3bucket_block_nm)

    airbyte_config = export_configuration(
        airbyte_server_port="8000",
        airbyte_server_host=hostname_secret.get()
    )

    write_export(
        export=airbyte_config, 
        bucket_block=s3_bucket_block, 
        filename=filename
    )


deployment = Deployment.build_from_flow(
    flow=airbyte_export,
    name="Airbyte Config Export",
    version="1",
    work_queue_name="prod",
    infrastructure=KubernetesJob.load("sync-airbyte_config"),
    tags=["prod-east"],
    storage=S3.load("airbyte-config-flow-storage")
    )


if __name__ == "__main__":
    # deployment.apply()
    airbyte_export(env="dev")