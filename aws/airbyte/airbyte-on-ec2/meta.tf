data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/main.zip"
}

data "aws_region" "current" {}