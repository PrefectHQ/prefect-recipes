resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-execution-role-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

data "aws_iam_policy_document" "lambda_exec" {
  version = "2012-10-17"

  statement {
    sid = "LambdaExecutionRole"

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "base_policy" {
  name        = "lambda-${var.function_name}-policy-${data.aws_region.current.name}"
  description = "IAM policy to allow lambda to delete vpcs across regions"

  policy = data.aws_iam_policy_document.base_policy.json
}

data "aws_iam_policy_document" "base_policy" {
  version = "2012-10-17"

  statement {
    sid = "LambdaAccountPermissions"

    actions = ["ec2:*"]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowCreationOfServiceLinkedRoles"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowLambdasAssumeRole"

    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"

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

resource "aws_iam_role_policy_attachment" "base" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.base_policy.arn
}