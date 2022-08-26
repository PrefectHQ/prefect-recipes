resource "aws_dynamodb_table" "DynamoDBTable" {
    attribute {
        name = "messageId"
        type = "S"
    }

    name = var.dbTableName
    hash_key = var.dbHashKey
    read_capacity = var.dbReadCapacity
    write_capacity = var.dbWriteCapacity
}

module "sqs_to_batch" {
  source = "./sqs_to_batch"

  #db_table_arn = aws_dynamodb_table.DynamoDBTable.arn
}


# resource "aws_cloudwatch_event_rule" "EventsRule" {
#     name = "state-change-in-batch"
#     description = "Fires when a batch job has changed states, and updates the change in DynamoDB"
#     event_pattern = "{\"source\":[\"aws.batch\"],\"detail-type\":[\"Batch Job State Change\"]}"
# }

# resource "aws_cloudwatch_event_target" "CloudWatchEventTarget" {
#     rule = "state-change-in-batch"
#     arn = "arn:aws:events:us-east-1:330830921905:rule/state-change-in-batch"
# }

# resource "aws_sqs_queue" "SQSQueue" {
#     delay_seconds = "5"
#     max_message_size = "262144"
#     message_retention_seconds = "86400"
#     receive_wait_time_seconds = "0"
#     visibility_timeout_seconds = "60"
#     name = "east-boyd-q1"
# }

# resource "aws_sqs_queue_policy" "SQSQueuePolicy" {
#     policy = "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__owner_statement\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::330830921905:root\"},\"Action\":\"SQS:*\",\"Resource\":\"arn:aws:sqs:us-east-1:330830921905:east-boyd-q1\"}]}"
#     queue_url = "https://sqs.us-east-1.amazonaws.com/330830921905/east-boyd-q1"
# }

# resource "aws_batch_compute_environment" "BatchComputeEnvironment" {
#     compute_environment_name = "Boyd_fargate"
#     type = "MANAGED"
#     state = "ENABLED"
#     service_role = "arn:aws:iam::330830921905:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
#     compute_resources {
#         type = "FARGATE"
#         max_vcpus = 16
#         subnets = [
#             "subnet-0a15883f99127a41b"
#         ]
#         security_group_ids = [
#             "sg-0aff45bb0baf81de9"
#         ]
#         tags {}
#     }
# }
