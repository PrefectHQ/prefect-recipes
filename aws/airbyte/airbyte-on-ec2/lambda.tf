resource "aws_lambda_function" "function" {
  description   = "Attaches Airbyte EBS volume to new instance spun up from ASG"
  function_name = "attach-airbyte-volume"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  handler       = "main.lambda_handler"
  timeout       = 180
  memory_size   = 128

  filename         = data.archive_file.source.output_path
  source_code_hash = data.archive_file.source.output_base64sha256

  environment {
    variables = {
      EBS_VOLUME_ID = aws_ebs_volume.airbyte.id
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/attach-airbyte-volume"
  retention_in_days = 30
}

resource "aws_cloudwatch_event_rule" "rule" {
  name        = "airbyte-asg-launch-new-instance"
  description = "Capture new airbyte instance launched by an auto-scaling group"

  event_pattern = <<EOF
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance Launch Successful"
  ],
  "detail": {
    "AutoScalingGroupName": [
      "airbyte-asg"
    ]
  }
}
EOF
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}

resource "aws_cloudwatch_event_target" "target" {
  arn  = aws_lambda_function.function.arn
  rule = aws_cloudwatch_event_rule.rule.id
}