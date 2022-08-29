resource "aws_sqs_queue" "SQSQueue" {
    delay_seconds = "5"
    max_message_size = "262144"
    message_retention_seconds = "86400"
    receive_wait_time_seconds = "0"
    visibility_timeout_seconds = "60"
    name = "sqs_to_batch"
}

resource "aws_lambda_event_source_mapping" "sqs_to_batch" {
    batch_size = 1
    event_source_arn = "${aws_sqs_queue.SQSQueue.arn}"
    function_name = "${aws_lambda_function.sqs_to_batch.arn}"
    enabled = true
}

# resource "aws_sqs_queue_policy" "SQSQueuePolicy" {
#     policy = "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__owner_statement\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::330830921905:root\"},\"Action\":\"SQS:*\",\"Resource\":\"arn:aws:sqs:us-east-1:330830921905:east-boyd-q1\"}]}"
#     queue_url = "https://sqs.us-east-1.amazonaws.com/330830921905/east-boyd-q1"
# }