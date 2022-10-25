from chalice import Chalice
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from time import time
from datetime import datetime
import boto3
import json

app = Chalice(app_name="batch-table-update")

dynamodb = boto3.resource("dynamodb")
TIME_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

# Main handler to receive eventbridge events
@app.lambda_function()
def lambda_handler(event, context):
    print(f"Event Received: {json.dumps(event)}")
    if event["detail"]["status"] in {"SUCCEEDED", "FAILED"}:
        messageId = event["detail"]["container"]["environment"][-1]["value"]
        timeRunning = get_runnable_time(messageId, event["time"])
        db_item = build_item(event, timeRunning)
    else:
        db_item = build_item(event)
    print(f"{db_item}")
    try:
        # write the flowId, jobId, jobState, timestamp, and jobName to dynamo
        
        write_to_dynamo(db_item)
        return generate_return_body("200", "Successfully updated DynamoDB")
    except ClientError as e:
        print("ClientError", e)
        return generate_return_body("500", str(e))

# Builds and returns the table row
def build_item(event, timeRunning=None):
    #432000 = 5 days = 5 * 24 hours * 60 minutes * 60 seconds
    ttl = 432000 + int(time())
    db_item = {
        "flowId": event["detail"]["container"]["environment"][-2]["value"],
        "messageId": event["detail"]["container"]["environment"][-1]["value"],
        "jobId": event["detail"]["jobId"],
        "batchState": event["detail"]["status"],
        "jobName": event["detail"]["jobName"],
        "jobQueue": event["detail"]["jobQueue"],
        "jobDefinition": event["detail"]["jobDefinition"],        
        "timeOfState": event["time"],
        "ttl": ttl
    }
    if timeRunning:
        created = int(event["detail"]["createdAt"]) // 1000
        start_time = datetime.fromtimestamp(created).strftime(TIME_FORMAT)

        db_item.update({"timeInRunnable": timeRunning})
        db_item.update({"startTime": start_time})
    if "logStreamName" in  event["detail"]["container"]:
        db_item.update({"logStreamName": event["detail"]["container"]["logStreamName"]})
        
    return db_item

def get_runnable_time(messageId, eventTime):
    table = dynamodb.Table("batch_state_table")
    response = table.query(KeyConditionExpression=Key("messageId").eq(messageId))
    timeOfRunningState = response["Items"][0]["timeOfState"]
    tic = datetime.strptime(eventTime, TIME_FORMAT)
    toc = datetime.strptime(timeOfRunningState, TIME_FORMAT)
    timeRunning = str(tic - toc)
    return timeRunning


# Writes the row to dynamoDB
def write_to_dynamo(db_item: dict):
    table = dynamodb.Table("batch_state_table")
    table.put_item(Item=db_item)


# Constructs a return payload for observability
def generate_return_body(status_code, message):
    return {"statusCode": status_code, "body": json.dumps({"message": message})}
