data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/main.zip"
}

data "aws_lambda_invocation" "delete_vpcs" {
  function_name = var.function_name

  input = <<JSON
{}
JSON

  depends_on = [
    aws_lambda_function.function
  ]
}