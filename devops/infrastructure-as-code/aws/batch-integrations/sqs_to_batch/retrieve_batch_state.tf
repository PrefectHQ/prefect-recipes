resource "aws_api_gateway_rest_api" "ApiGatewayRestApi" {
  name        = "get-batchjob-state"
  description = "Batch State Lambda API Gateway"
  #exports execution_arn to be used by source_arn in lambda_permission
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  parent      = aws_api_gateway_rest_api.ApiGatewayRestApi.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
  rest_api_id   = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "retrieve_batch_state" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_resource.proxy.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retrieve_batch_state.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "retrieve_batch_state_root" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
  resource_id = aws_api_gateway_resource.proxy_root.id
  http_method = aws_api_gateway_resource.proxy_root.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.retrieve_batch_state.invoke_arn
}


resource "aws_api_gateway_deployment" "ApiGatewayDeployment" {
  rest_api_id = aws_api_gateway_rest_api.ApiGatewayRestApi.id
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
                "arn:aws:dynamodb:*:330830921905:table/batch_state_table/index/*",
                "arn:aws:dynamodb:us-east-1:330830921905:table/batch_state_table"
            ]
        }
    ]
}
EOF
  role   = aws_iam_role.retrieve_batch_state.name
}

resource "aws_lambda_permission" "retrieve_batch_state" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retrieve_batch_state.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ApiGatewayRestApi.execution_arn}/*/*"
}

resource "aws_lambda_function" "retrieve_batch_state" {
  description   = ""
  function_name = aws_iam_role.retrieve_batch_state.name
  handler       = "app.app"
  architectures = [
    "x86_64"
  ]
  filename    = "./sqs_to_batch/retrieve_batch_state/deployment.zip"
  memory_size = 128
  role        = aws_iam_role.IAMRole.arn
  runtime     = "python3.9"
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
}