data "aws_iam_policy_document" "update_batch_table" {

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
      "dynamodb:PutItem",
    ]
    resources = [
      "${var.dynamo_db_table_arn}",
    ]
  }
}

resource "aws_iam_role" "update_batch_table" {
  name = "batch-table-update-dev"

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

resource "aws_iam_policy" "update_batch_table" {
  name   = "update_batch_table-dev"
  policy = data.aws_iam_policy_document.update_batch_table.json
}

resource "aws_iam_policy_attachment" "update_batch_table" {
  name       = "update_batch_table-dev"
  roles      = [aws_iam_role.update_batch_table.name]
  policy_arn = aws_iam_policy.update_batch_table.arn
}


resource "aws_lambda_function" "batch_table_update" {
  description   = ""
  function_name = "batch-table-update-lambda_handler"
  handler       = "app.lambda_handler"
  architectures = [
    "x86_64"
  ]

  filename    = "./sqs_to_batch/update_batch_table/deployment.zip"
  memory_size = 128
  role        = aws_iam_role.update_batch_table.arn
  runtime     = "python3.9"
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_cloudwatch_event_rule" "EventsRule" {
  name          = "state-change-in-batch"
  description   = "Fires when a batch job has changed states, and updates the change in DynamoDB"
  event_pattern = "{\"source\":[\"aws.batch\"],\"detail-type\":[\"Batch Job State Change\"]}"
}

resource "aws_cloudwatch_event_target" "CloudWatchEventTarget" {
  rule = aws_cloudwatch_event_rule.EventsRule.name
  arn  = aws_lambda_function.batch_table_update.arn
}

resource "aws_lambda_permission" "batch_table_update" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_table_update.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EventsRule.arn
}

resource "aws_cloudwatch_log_group" "batch_table_update" {
    name = "/aws/lambda/${aws_lambda_function.batch_table_update.function_name}"
    retention_in_days = 5
}

# resource "aws_lambda_permission" "batch_table_update" {
#     action = "lambda:InvokeFunction"
#     function_name = "${aws_lambda_function.batch_table_update.arn}"
#     principal = "events.amazonaws.com"
#     source_arn = "arn:aws:events:us-east-1:330830921905:rule/state-change-in-batch"
# }