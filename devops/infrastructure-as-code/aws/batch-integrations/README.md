# AWS Queue to Batch Implementation

## Purpose 
The AWS Batch submit job has an API limit of 50 transactions per second.
Submitted jobs / tasks / flows that exceed this limit are dropped and failed without retry.
This queue-to-batch implentation detailed in depth below intends to remediate this issue through AWS native services.
The end result is increased throughput and utilization. 
A 2nd order effect of this increased throughput will have increased operating costs, as more batch jobs run concurrently than previously.

## Components
There are a number of components implemented for this solution. 
Some of these components are per account (per batch compute environment), and some are singular, across all accounts.
Inputs and outputs for each component are detailed further down.

| Single Implementation | Name of Object | 
| ----------- | ---------- |
| DynamoDB Table | `batch_state_table`
| Retreieve State Lambda |  `retrieve_batch_state`

| Per AWS Account | Name of Item | 
| ----------- | ---------- | 
| SQS Queue | `sqs_to_batch` |
| Queue to Batch Lambda | `queue_to_batch` | 
| Update Batch Table Lambda | `update_batch_table` |
| Eventbridge Rule Trigger | `state-change-in-batch` |

# Architecture Diagram


# Task Walkthrough

1) Submit  to SQS
2) Queue to Batch
3) Eventbridge Triggers + DynamoDB Updates
4) State Retrieval

## 1 - Submit to SQS
A task submits a minimum required set of parameters to be started as a Batch Job.
The example below is a minimal viable example.
- `jobName` is the name of the job to be executed in Batch
- `jobQueue` is the AWS Batch queue to be submitted to. 
- `jobDefinition` is the AWS Batch Job Definition to describe the infrastructure to provision
- `flowId` is passed through from the calling Task / Flow. It is not required, but suggested for later visibility.

```
# Setup k:v parameters for submitting a batch_job.
    message = {
        "jobName": "",
        "jobQueue": "",
        "jobDefinition": "",
        "flowId": "",
    }
# Retrieve the queue_url by name - the name is static per AWS account.
    queue_url = sqs.get_queue_url(
        QueueName="sqs_to_batch",
        QueueOwnerAWSAccountId="< Account Owner ID > "
    )
# SQS only accepts a string, convert 'message' to string.
    data = json.dumps(message)
# Submit our message.
    response = sqs.send_message(QueueUrl=queue_url['QueueUrl'], MessageBody=data)
```

A successful submission to the SQS queue returns the following response. The `MessageId` field will be used for status retrieval from DynamoDB.
```
{
    'MD5OfMessageBody': 'string',
    'MD5OfMessageAttributes': 'string',
    'MD5OfMessageSystemAttributes': 'string',
    'MessageId': 'string',
    'SequenceNumber': 'string'
}
```

## 2 - Queue to Batch
Messages in the queue are read off as events by the `queue_to_batch` Lambda, and submitted to Batch. Any failed responses from AWS Batch are re-queued.
This Lambda unpacks the message with the `submit-jobs` parameters in #1, in addition to embedding two values for lookup later in DynamoDB: `flowId` and `messageId`.
The submission to batch looks as below. `jobDefinition`, `jobName`, and `jobQueue` are all required parameters passed in 1. `**job_details` unpacks any additional kwargs in the body of `job_details`, such as `containerOverrides`.
```
        response = batch.submit_job(
            jobDefinition=jobDefinition,
            jobName=jobName,
            jobQueue=jobQueue,
            **job_details
        )
```

## 3 - Eventbridge Triggers + DynamoDB Updates
Once the Batch Job has been submitted, an Eventbridge Rule is listening for Batch Job State changes.
As a batch job transitions state (`PENDING`, `SCHEDULED`, `STARTING`, `RUNNING`, etc.), the `update_batch_table` Lambda is triggered.
This Lambda adds the following columns for each entry as a `put_item` entry, meaning an existing item with the same key is overwrriten.
```
    db_item = {
        "flowId": event["detail"]["container"]["environment"][0]["value"],
        "messageId": event["detail"]["container"]["environment"][1]["value"],
        "jobId": event["detail"]["jobId"],
        "batchState": event["detail"]["status"],
        "jobName": event["detail"]["jobName"],
        "jobQueue": event["detail"]["jobQueue"],
        "jobDefinition": event["detail"]["jobDefinition"],        
        "timeOfState": event["time"],
        "ttl": ttl
    }
```

## 4 - State Retrieval
The `retrieve_batch_state` URL can be invoked asynchronously at any time.
The initial task can call the `/describe-jobs/messageid/{messageid}` route, with the messageid response it received in 1.
An example of what the task might use is below:
```
LAMBDA = "https://abcdefgh.execute-api.us-east-1.amazonaws.com/api/"
MESSAGEID = b994f4b0-e2ee-4116-bbbc-aaf9d7562298

curl  $LAMBDA/describe-jobs/messageid/$MESSAGEID
{"messageId":"b994f4b0-e2ee-4116-bbbc-aaf9d7562298","flowId":"abcd-1234","jobId":"dbe4b187-2379-4d1c-9f02-0dae20be6783","State":"SUCCEEDED"}
```

The following methods are available:

| URI | Method | Parameter | Response | Description |
| ----------- | ---------- |  ---------- |  ---------- | -------- |
| /describe-jobs/ | `GET` | No | {"SUCCEEDED":3} | Returns the number of Batch Jobs in each state, as a table.  |
| /describe-jobs/{STATE} | `GET` | `SCHEDULED`, `SUBMITTED`, `PENDING`, `RUNNABLE`, `STARTING`, `RUNNING`, `SUCCEEDED`, `FAILED` | `[{"messageId":"9d02224b-7a72-4715-91f2-0b2df0dead91","timeElapsed":"8 days, 20:38:27.270997","flowId":"t"},{"messageId":"2b98fa31-3a17-4b8c-b998-b038788cd04b","timeElapsed":"22:30:01.270997","flowId":""},{"messageId":"b994f4b0-e2ee-4116-bbbc-aaf9d7562298","timeElapsed":"2:00:03.270997","flowId":""}]` | Returns a list of rows in the requested `{STATE}`.
| /describe-jobs/messageid/{messageid} | `GET` | `9d02224b-7a72-4715-91f2-0b2df0dead91` | `{"messageId":"9d02224b-7a72-4715-91f2-0b2df0dead91","flowId":"bcd-gh-5678","jobId":"b255bbef-372c-46d5-98e8-0637c95f5843","State":"SUCCEEDED"}` | Returns the row for the queried `messageid`.


