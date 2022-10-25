# Name of the api-gateway
resource "aws_api_gateway_rest_api" "retrieve_batch_state" {
  name        = "get-batchjob-state"
  description = "Batch State Lambda API Gateway"
}

# Route for /describe-jobs on the gateway
resource "aws_api_gateway_resource" "describe_jobs" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  parent_id   = aws_api_gateway_rest_api.retrieve_batch_state.root_resource_id
  path_part   = "describe-jobs"
}

# Route for /{state} variable on the gateway.
resource "aws_api_gateway_resource" "state" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  parent_id   = aws_api_gateway_resource.describe_jobs.id
  path_part   = "{state}"
}

# Route for /messageid/ on the gateway
resource "aws_api_gateway_resource" "message_id" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  parent_id   = aws_api_gateway_resource.describe_jobs.id
  path_part   = "messageid"

}

# Route for the variable - goes to /messageid/{messageId} on the gateway
resource "aws_api_gateway_resource" "message_id_2" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  parent_id   = aws_api_gateway_resource.message_id.id
  path_part   = "{messageId}"
}

# Allowed http verb on /describe-jobs route
resource "aws_api_gateway_method" "describe_jobs" {
  rest_api_id      = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id      = aws_api_gateway_resource.describe_jobs.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

# Allowed http verb on /{state} route
resource "aws_api_gateway_method" "state" {
  rest_api_id      = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id      = aws_api_gateway_resource.state.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.state" = true
  }
}

# Allowed http verb on /messageid/{messageId} route
resource "aws_api_gateway_method" "message_id_2" {
  rest_api_id      = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id      = aws_api_gateway_resource.message_id_2.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.messageId" = true
  }
}

# Maps the lambda trigger to the describe-jobs route
resource "aws_api_gateway_integration" "describe_jobs" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id = aws_api_gateway_resource.describe_jobs.id
  http_method = aws_api_gateway_method.describe_jobs.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retrieve_batch_state.invoke_arn
}

# Maps the lambda trigger to the {state} route
resource "aws_api_gateway_integration" "state" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id = aws_api_gateway_resource.state.id
  http_method = aws_api_gateway_method.state.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retrieve_batch_state.invoke_arn
}

# Maps the lambda trigger to the {messageId} route
resource "aws_api_gateway_integration" "message_id_2" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id = aws_api_gateway_resource.message_id_2.id
  http_method = aws_api_gateway_method.message_id_2.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retrieve_batch_state.invoke_arn
}

# Provides the return status for /describe-jobs
resource "aws_api_gateway_method_response" "describe_jobs" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
  resource_id = aws_api_gateway_resource.describe_jobs.id
  http_method = aws_api_gateway_method.describe_jobs.http_method
  status_code = "200"
}

# Assigns the primary stage for the api-gateway
resource "aws_api_gateway_stage" "retrieve_batch_state" {
  stage_name            = "api"
  deployment_id         = aws_api_gateway_deployment.retrieve_batch_state.id
  rest_api_id           = aws_api_gateway_rest_api.retrieve_batch_state.id
  cache_cluster_enabled = false
  xray_tracing_enabled  = false
}

# Creates the api gateway
resource "aws_api_gateway_deployment" "retrieve_batch_state" {
  rest_api_id = aws_api_gateway_rest_api.retrieve_batch_state.id
}

# Assigns iam_role - allows api-gateway to invoke Lambda
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

# Policy for the lambda - requires logs:CreateStream,CreateLogGroup and put events for Lambda), dbGet, dbScan, dbQuery for DB
# The resources permit any account + any region to explicitly write to batch_state_table and the index ARN. 
# This enables other accounts in other regions to write to the master table + index.
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
  role   = aws_iam_role.retrieve_batch_state.name
}

#  Maps Gateway Invoke to the Lambda to call
resource "aws_lambda_permission" "retrieve_batch_state" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retrieve_batch_state.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.retrieve_batch_state.execution_arn}/*/*"
}

# Deploys the lambda - deployed from deployment.zip; changes need to be made to the app.py, and repackaged with chalice
resource "aws_lambda_function" "retrieve_batch_state" {
  description   = ""
  function_name = aws_iam_role.retrieve_batch_state.name
  handler       = "app.app"
  architectures = [
    "x86_64"
  ]
  filename    = "./retrieve_batch_state/deployment.zip"
  memory_size = 128
  role        = aws_iam_role.retrieve_batch_state.arn
  runtime     = "python3.9"
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_cloudwatch_log_group" "retrieve_batch_state" {
  name              = "/aws/lambda/${aws_lambda_function.retrieve_batch_state.function_name}"
  retention_in_days = 5
}
