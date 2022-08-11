# nate@prefect.io - 10/18/21
# aws lambda-based, event-driven flow trigger
# using example event: s3:ObjectCreated:*

import logging
import os
from typing import Any, Dict

import boto3

import prefect
from prefect.run_configs.kubernetes import KubernetesRun

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get secret(s) from AWS Systems Manager Parameter Store
ssm = boto3.client("ssm")
PREFECT_AUTH_TOKEN = ssm.get_parameter(Name="keyName")
prefect_client = prefect.Client(api_key=PREFECT_AUTH_TOKEN)


# kick-off flow run with prefect.Client instance
def trigger_flow_run(params: Dict[str, Any]) -> dict:
    return prefect_client.create_flow_run(
        parameters=params,
        version_group_id=os.getenv("PREFECT_VERSION_GROUP_ID"),
        run_config=KubernetesRun(),
    )


# parse new S3 object as needed for flow params
def parse(s3_object: object) -> dict:
    # TODO
    return dict()


# parse event JSON (e.g. S3 ObjectCreated -> flow params)
def run(event, context):
    s3 = boto3.resource("s3")
    s3_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    s3_key = event["Records"][0]["s3"]["object"]["key"]
    s3_object = s3.Object(s3_bucket, s3_key)

    params = parse(s3_object)

    try:
        trigger_flow_run(params)
        return {"success": True}

    except prefect.Client.ClientError:
        raise
