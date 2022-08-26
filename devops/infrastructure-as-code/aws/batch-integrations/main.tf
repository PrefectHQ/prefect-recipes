resource "aws_dynamodb_table" "DynamoDBTable" {
    attribute {
        name = "messageId"
        type = "S"
    }
    name = "boyd_batch_2"
    hash_key = "messageId"
    read_capacity = 1
    write_capacity = 1
}

resource "aws_lambda_function" "LambdaFunction" {
    description = ""
    environment {
        variables {}
    }
    function_name = "batch-table-update-dev-lambda_handler"
    handler = "app.lambda_handler"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "prod-04-2014-tasks"
    s3_key = "/snapshots/330830921905/batch-table-update-dev-lambda_handler-bf0c22b7-cf00-4972-bfd1-93282a9422f8"
    s3_object_version = "MjnsUcsHPG1Vp7kcCLEj.IQbw6VM01MM"
    memory_size = 128
    role = "arn:aws:iam::330830921905:role/batch-table-update-dev"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "LambdaFunction2" {
    description = ""
    function_name = "get-batchjob-state-dev"
    handler = "app.app"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "prod-04-2014-tasks"
    s3_key = "/snapshots/330830921905/get-batchjob-state-dev-0a7db025-fb59-4706-af4d-d0c131eec313"
    s3_object_version = "hctwzahvc7Xc9qmmdBSpWB.HcFk2sn_3"
    memory_size = 128
    role = "arn:aws:iam::330830921905:role/get-batchjob-state-dev-api_handler"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "LambdaFunction3" {
    description = ""
    environment {
        variables {}
    }
    function_name = "sqs-to-batch-dev-handler"
    handler = "app.handler"
    architectures = [
        "x86_64"
    ]
    s3_bucket = "prod-04-2014-tasks"
    s3_key = "/snapshots/330830921905/sqs-to-batch-dev-handler-0c67d2f9-61a4-4707-98c2-8479a9890dbe"
    s3_object_version = "kxiY7z1nn.NKgQ93X4JfJXRiXGMIuh4a"
    memory_size = 128
    role = "arn:aws:iam::330830921905:role/sqs-to-batch-dev"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_permission" "LambdaPermission" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction.arn}"
    principal = "events.amazonaws.com"
    source_arn = "arn:aws:events:us-east-1:330830921905:rule/state-change-in-batch"
}

resource "aws_lambda_permission" "LambdaPermission2" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction2.arn}"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:us-east-1:330830921905:gscx3uncki/*"
}

resource "aws_lambda_permission" "LambdaPermission3" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambdaFunction2.arn}"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:us-east-1:330830921905:q3yrw5zyvl/*"
}

resource "aws_cloudwatch_event_rule" "EventsRule" {
    name = "state-change-in-batch"
    description = "Fires when a batch job has changed states, and updates the change in DynamoDB"
    event_pattern = "{\"source\":[\"aws.batch\"],\"detail-type\":[\"Batch Job State Change\"]}"
}

resource "aws_cloudwatch_event_target" "CloudWatchEventTarget" {
    rule = "state-change-in-batch"
    arn = "arn:aws:events:us-east-1:330830921905:rule/state-change-in-batch"
}

resource "aws_sqs_queue" "SQSQueue" {
    delay_seconds = "5"
    max_message_size = "262144"
    message_retention_seconds = "86400"
    receive_wait_time_seconds = "0"
    visibility_timeout_seconds = "60"
    name = "east-boyd-q1"
}

resource "aws_sqs_queue_policy" "SQSQueuePolicy" {
    policy = "{\"Version\":\"2008-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"__owner_statement\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::330830921905:root\"},\"Action\":\"SQS:*\",\"Resource\":\"arn:aws:sqs:us-east-1:330830921905:east-boyd-q1\"}]}"
    queue_url = "https://sqs.us-east-1.amazonaws.com/330830921905/east-boyd-q1"
}

resource "aws_batch_compute_environment" "BatchComputeEnvironment" {
    compute_environment_name = "Boyd_fargate"
    type = "MANAGED"
    state = "ENABLED"
    service_role = "arn:aws:iam::330830921905:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
    compute_resources {
        type = "FARGATE"
        max_vcpus = 16
        subnets = [
            "subnet-0a15883f99127a41b"
        ]
        security_group_ids = [
            "sg-0aff45bb0baf81de9"
        ]
        tags {}
    }
}
