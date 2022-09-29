data "aws_iam_policy_document" "sqs_batch" {
  statement {
    sid = ""

    actions = [
      "batch:SubmitJob",
    ]
    resources = [
      "*",
    ]
  }

  statement {

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:*:logs:*:*:*",
    ]
  }

  statement {

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "sqs_batch" {
  name = "sqs-to-batch-dev"

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

resource "aws_iam_policy" "sqs_batch" {
  name   = "sqs-to-batch-dev"
  policy = data.aws_iam_policy_document.sqs_batch.json
}

resource "aws_iam_policy_attachment" "sqs_batch" {
  name       = "sqs-to-batch-dev"
  roles      = [aws_iam_role.sqs_batch.name]
  policy_arn = aws_iam_policy.sqs_batch.arn
}


resource "aws_lambda_function" "sqs_to_batch" {
  description   = ""
  function_name = "sqs-to-batch-dev-handler"
  handler       = "app.handler"
  architectures = [
    "x86_64"
  ]

  filename    = "./sqs_to_batch/queue_to_batch/deployment.zip"
  memory_size = 128
  role        = aws_iam_role.sqs_batch.arn
  runtime     = "python3.9"
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
}


resource "aws_cloudwatch_log_group" "sqs_to_batch" {
  name              = "/aws/lambda/${aws_lambda_function.sqs_to_batch.function_name}"
  retention_in_days = 5
}