from boto3.dynamodb.conditions import Attr, Key
from chalice import Chalice
from collections import Counter
from datetime import datetime
import boto3
import json

app = Chalice(app_name="get-batchjob-state")
TIME_FORMAT = "%Y-%m-%dT%H:%M:%SZ"
dynamodb = boto3.resource("dynamodb")


@app.route("/describe-jobs")
def describe_jobs():
    response = table_lookup()
    count = Counter(msg["batchState"] for msg in response)

    return count


@app.route("/describe-jobs/{state}")
def describe_job_state(state):
    STATES = {
        "SCHEDULED",
        "SUBMITTED",
        "PENDING",
        "RUNNABLE",
        "STARTING",
        "RUNNING",
        "SUCCEEDED",
        "FAILED",
    }
    if state not in STATES:
        response = f"Valid states are: {STATES}"
        print(response)
        return response
    response = table_lookup(state)
    toc = datetime.now()
    all_replies = {}
    for item in response:
        time_dif = toc - datetime.strptime(item["timeOfState"], TIME_FORMAT)
        all_replies[item["flowId"]] = [
            f"Batch Job ID: {item['jobId']}",
            f"Time Elapsed: {time_dif}",
        ]
    return all_replies


@app.route("/describe-jobs/messageid/{messageId}")
def batch_lookup_job(messageId):
    table = dynamodb.Table("boyd_batch_2")
    response = table.query(KeyConditionExpression=Key("messageId").eq(messageId))
    items = response["Items"][0]
    id_query = {
        "messageId": items["messageId"],
        "flowId": items["flowId"],
        "jobId": items["jobId"],
        "State": items["batchState"],
    }
    return id_query


def table_lookup(state=None):
    table = dynamodb.Table("boyd_batch_2")
    if state:
        filter_expression = Attr("batchState").eq(state)
    else:
        filter_expression = Attr("timeOfState").gt("0")
    response = table.scan(FilterExpression=filter_expression)
    data = response["Items"]
    while "LastEvaluatedKey" in response:
        response = table.scan(
            ExclusiveStartKey=response["LastEvaluatedKey"],
            FilterExpression=filter_expression,
        )
        data.extend(response["Items"])

    return data


def generate_return_body(status_code, message):
    return {"statusCode": status_code, "body": json.dumps({"message": message})}
