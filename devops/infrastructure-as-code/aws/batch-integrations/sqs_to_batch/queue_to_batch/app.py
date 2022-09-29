import json
import boto3
from chalice import Chalice


app = Chalice(app_name="sqs-to-batch-lambda")


@app.on_sqs_message(queue="sqs_to_batch")
def handler(event):
    new_event = event.to_dict()
    for record in new_event["Records"]:

        job_details = json.loads(record["body"])
        messageId = record["messageId"]
        # Pop jobName, Queue and Definition off job_details

        jobName = job_details.pop("jobName")
        jobQueue = job_details.pop("jobQueue")
        jobDefinition = job_details.pop("jobDefinition")
        flowId = job_details.pop("flowId")
        sqsQueue = job_details.pop("sqsQueue")
        # Need to inject flowId and messageId to make it to DynamoDB
        container_overrides = {
            "environment": [
                {"name": "flow_id", "value": flowId},
                {"name": "messageId", "value": messageId},
            ]
        }
        # If containerOverrides came in empty, set the required fields, otherwise update them.
        if "environment" not in job_details["containerOverrides"]:
            job_details["containerOverrides"].update(container_overrides)
        elif "messageId" not in job_details["containerOverrides"]["environment"]:
            job_details["containerOverrides"].update(container_overrides)
        else:
            print(
                f"This is a re-submitted flow with existing environment: {job_details['containerOverrides']['environment'] = }"
            )

        print(
            f"""Job Name: {jobName} \
                Job Queue: {jobQueue} \
                Job Definition: {jobDefinition} \
                Flow ID: {container_overrides['environment'][-2]['value']} \
                Message ID: {container_overrides['environment'][-1]['value']}
                """
        )
        batch = boto3.client("batch")

        print(", ".join(["{}={!r}".format(k, v) for k, v in job_details.items()]))
        response = batch.submit_job(
            jobDefinition=jobDefinition,
            jobName=jobName,
            jobQueue=jobQueue,
            **job_details,
        )

        print(json.dumps(response, indent=4))
