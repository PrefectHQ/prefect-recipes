resource "aws_lambda_function" "sqs_to_batch" {
    description = ""
    function_name = "sqs-to-batch-dev-handler"
    handler = "app.handler"
    architectures = [
        "x86_64"
    ]

    filename = "./sqs_to_batch/queue_to_batch/deployment.zip"
    memory_size = 128
    role = aws_iam_role.sqs_batch.arn #"arn:aws:iam::330830921905:role/sqs-to-batch-dev"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "batch_table_update" {
    description = ""
    function_name = "batch-table-update-lambda_handler"
    handler = "app.lambda_handler"
    architectures = [
        "x86_64"
    ]

    filename = "./sqs_to_batch/update_batch_table/update_batch_table.zip"
    memory_size = 128
    role = "arn:aws:iam::330830921905:role/batch-table-update-dev"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}

resource "aws_lambda_function" "get_batchjob_state" {
    description = ""
    function_name = "get-batchjob-state-dev"
    handler = "app.app"
    architectures = [
        "x86_64"
    ]

    filename = "./sqs_to_batch/retrieve_batch_state/get_batchjob_state.zip"

    memory_size = 128
    role = "arn:aws:iam::330830921905:role/get-batchjob-state-dev-api_handler"
    runtime = "python3.9"
    timeout = 60
    tracing_config {
        mode = "PassThrough"
    }
}




# resource "aws_lambda_permission" "LambdaPermission" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.LambdaFunction.arn}"
#     principal = "events.amazonaws.com"
#     source_arn = "arn:aws:events:us-east-1:330830921905:rule/state-change-in-batch"
# }

# resource "aws_lambda_permission" "LambdaPermission2" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.LambdaFunction2.arn}"
#     principal = "apigateway.amazonaws.com"
#     source_arn = "arn:aws:execute-api:us-east-1:330830921905:gscx3uncki/*"
# }

# resource "aws_lambda_permission" "LambdaPermission3" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.LambdaFunction2.arn}"
#     principal = "apigateway.amazonaws.com"
#     source_arn = "arn:aws:execute-api:us-east-1:330830921905:q3yrw5zyvl/*"
# }