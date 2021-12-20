resource "aws_lambda_function" "function" {
  description   = "Pulls all regions and loops through to remove default VPC and associated resources"
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.8"
  handler       = "main.lambda_handler"
  timeout       = 180
  memory_size   = 128


  filename         = data.archive_file.source.output_path
  source_code_hash = data.archive_file.source.output_base64sha256
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 30
}