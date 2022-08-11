resource "aws_iam_role" "lambda" {
  name_prefix        = "${var.function_name}-execution"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  version = "2012-10-17"

  statement {
    sid     = "LambdaExecutionRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda" {
  name_prefix = "lambda-${var.function_name}"
  description = "IAM policy to allow lambda to delete vpcs across regions"
  policy      = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" { #tfsec:ignore:aws-iam-no-policy-wildcards
  version = "2012-10-17"

  statement {
    sid       = "LambdaAccountPermissions"
    actions   = ["ec2:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowCreationOfServiceLinkedRoles"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowLambdasAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "LambdaLogGroupPermissions"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}