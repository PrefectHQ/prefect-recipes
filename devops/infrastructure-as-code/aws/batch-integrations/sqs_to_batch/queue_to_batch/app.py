import json
import boto3
from chalice import Chalice

app = Chalice(app_name="sqs-to-batch-lambda")

#@app.on_sqs_message(queue="east-boyd-q1")
@app.on_sqs_message(queue=queue)
def handler(event):
    new_event = event.to_dict()
    for record in new_event["Records"]:
        job_details = json.loads(record["body"])
        messageId = record["messageId"]
        jobName = job_details.pop("jobName")
        jobQueue = job_details.pop("jobQueue")
        jobDefinition = job_details.pop("jobDefinition")
        containerOverrides = {
            "environment": [
                {"name": "flow_id", "value": job_details["flowId"]},
                {"name": "messageId", "value": messageId},
            ]
        }
        print(
            f"""Job Name: {jobName} \
                Job Queue: {jobQueue} \
                Job Definition: {jobDefinition} \
                Flow ID: {containerOverrides['environment'][0]['value']} \
                Message ID: {containerOverrides['environment'][1]['value']}
                """
        )
        batch = boto3.client("batch")

        response = batch.submit_job(
            jobDefinition=jobDefinition,
            jobName=jobName,
            jobQueue=jobQueue,
            containerOverrides=containerOverrides,
        )

        print(json.dumps(response, indent=4))
