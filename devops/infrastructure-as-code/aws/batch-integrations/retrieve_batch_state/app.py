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
    if str(state).upper() not in STATES:
        response = f"Valid states are: {STATES}"
        print(response)
        return response
    response = query_by_state(state)
    toc = datetime.now()
    list_of_replies = []

    for item in response:
        row = {
            "messageId": "",
            "timeElapsed": "",
            "flowId":""
        }
        time_dif = toc - datetime.strptime(item["timeOfState"], TIME_FORMAT)
        row['messageId'] = item['messageId']
        row['timeElapsed'] = f"{time_dif}"
        row['flowId'] = "Not there yet"
        list_of_replies.append(row)
    print (list_of_replies)
    return list_of_replies


@app.route("/describe-jobs/messageid/{messageId}")
def batch_lookup_job(messageId):
    table = dynamodb.Table("batch_state_table")
    response = table.query(KeyConditionExpression=Key("messageId").eq(messageId))
    items = response["Items"][0]
    id_query = {
        "messageId": items["messageId"],
        "flowId": items["flowId"],
        "jobId": items["jobId"],
        "State": items["batchState"],
    }
    return id_query


def table_lookup():
    table = dynamodb.Table("batch_state_table")
    response = table.scan()
    data = response["Items"]
    while "LastEvaluatedKey" in response:
        response = table.scan(
            ExclusiveStartKey=response["LastEvaluatedKey"],
        )
        data.extend(response["Items"])

    return data

def query_by_state(state):
    table = dynamodb.Table("batch_state_table")
    response = table.query(
        KeyConditionExpression=Key('batchState').eq(state),
        IndexName="batchState-timeOfState-index"
    )
    data = response["Items"]
    while "LastEvaluatedKey" in response:
        response = table.query(
            ExclusiveStartKey=response["LastEvaluatedKey"],
            KeyConditionExpression=Key('batchState').eq(state),
            IndexName="batchState-timeOfState-index"
        )
        data.extend(response["Items"])

    return data

def generate_return_body(status_code, message):
    return {"statusCode": status_code, "body": json.dumps({"message": message})}
