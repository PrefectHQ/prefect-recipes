resource "aws_api_gateway_rest_api" "retrieve_batch_state" {
  name        = "get-batchjob-state"
  description = "Batch State Lambda API Gateway"
}


resource "aws_api_gateway_resource" "describe_jobs" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    parent_id   = "${aws_api_gateway_rest_api.retrieve_batch_state.root_resource_id}"
    path_part   = "describe-jobs"
}

resource "aws_api_gateway_resource" "state" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    parent_id   = "${aws_api_gateway_resource.describe_jobs.id}"
    path_part   = "{state}"
}

resource "aws_api_gateway_resource" "message_id" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    parent_id   = "${aws_api_gateway_resource.describe_jobs.id}"
    path_part   = "messageid"

}

resource "aws_api_gateway_resource" "message_id_2" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    parent_id   = "${aws_api_gateway_resource.message_id.id}"
    path_part   = "{messageId}"
}

resource "aws_api_gateway_method" "describe_jobs" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.describe_jobs.id}"
    http_method = "GET"
    authorization = "NONE"
    api_key_required = false
}

resource "aws_api_gateway_method" "state" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.state.id}"
    http_method = "GET"
    authorization = "NONE"
    api_key_required = false
    request_parameters = {
        "method.request.path.state" = true
    }
}


resource "aws_api_gateway_method" "message_id_2" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.message_id_2.id}"
    http_method = "GET"
    authorization = "NONE"
    api_key_required = false
    request_parameters = {
        "method.request.path.messageId" = true
    }
}

resource "aws_api_gateway_integration" "describe_jobs" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.describe_jobs.id}"
    http_method = "${aws_api_gateway_method.describe_jobs.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.retrieve_batch_state.invoke_arn}"
}

resource "aws_api_gateway_integration" "state" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.state.id}"
    http_method = "${aws_api_gateway_method.state.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.retrieve_batch_state.invoke_arn}"
}


resource "aws_api_gateway_integration" "message_id_2" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.message_id_2.id}"
    http_method = "${aws_api_gateway_method.message_id_2.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.retrieve_batch_state.invoke_arn}"
}

resource "aws_api_gateway_method_response" "describe_jobs" {
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    resource_id = "${aws_api_gateway_resource.describe_jobs.id}"
    http_method = "${aws_api_gateway_method.describe_jobs.http_method}"
    status_code = "200"
}

resource "aws_api_gateway_stage" "retrieve_batch_state" {
    stage_name = "api"
    deployment_id = "${aws_api_gateway_deployment.retrieve_batch_state.id}"
    rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
    cache_cluster_enabled = false
    xray_tracing_enabled = false
}

resource "aws_api_gateway_deployment" "retrieve_batch_state" {
  rest_api_id = "${aws_api_gateway_rest_api.retrieve_batch_state.id}"
}

resource "aws_iam_role" "retrieve_batch_state" {
  name = "retrieve_batch_state-dev"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "retrieve_batch_state" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:*:logs:*:*:*",
                "arn:aws:dynamodb:*:*:table/batch_state_table/index/*",
                "arn:aws:dynamodb:*:*:table/batch_state_table"
            ]
        }
    ]
}
EOF
  role   = "${aws_iam_role.retrieve_batch_state.name}"
}

resource "aws_lambda_permission" "retrieve_batch_state" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retrieve_batch_state.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.retrieve_batch_state.execution_arn}/*/*"
}

resource "aws_lambda_function" "retrieve_batch_state" {
  description   = ""
  function_name = aws_iam_role.retrieve_batch_state.name
  handler       = "app.app"
  architectures = [
    "x86_64"
  ]
  filename    = "./retrieve_batch_state/deployment.zip"
  memory_size = 128
  role        = "${aws_iam_role.retrieve_batch_state.arn}"
  runtime     = "python3.9"
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_cloudwatch_log_group" "retrieve_batch_state" {
    name = "/aws/lambda/${aws_lambda_function.retrieve_batch_state.function_name}"
    retention_in_days = 5
}
