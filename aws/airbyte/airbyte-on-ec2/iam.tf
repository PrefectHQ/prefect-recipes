resource "aws_iam_instance_profile" "instance_profile" {
  name = "airbyte-instance-profile"
  role = aws_iam_role.airbyte_role.name
}

resource "aws_iam_role" "airbyte_role" {
  name               = "airbyte-role"
  assume_role_policy = data.aws_iam_policy_document.airbyte_assume_policy.json
}

data "aws_iam_policy_document" "airbyte_assume_policy" {
  version = "2012-10-17"

  statement {

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "airbyte_policy" {
  version = "2012-10-17"

  statement {
    sid = "allowlogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "airbyte_policy" {
  name        = "ec2-airbyte-policy"
  description = "IAM policy to allow airbyte instance to ship logs to cwl"

  policy = data.aws_iam_policy_document.airbyte_policy.json
}

resource "aws_iam_role_policy_attachment" "airbyte_policy" {
  role       = aws_iam_role.airbyte_role.name
  policy_arn = aws_iam_policy.airbyte_policy.arn
}

resource "aws_iam_policy_attachment" "ssm_policy" {
  name       = "ssm-policy-attachment"
  roles      = [aws_iam_role.airbyte_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-attach-airbyte-volume-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

data "aws_iam_policy_document" "lambda_assume_policy" {
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

data "aws_iam_policy_document" "lambda_policy" {
  version = "2012-10-17"

  statement {
    sid = "LambdaAccountPermissions"

    actions = ["ec2:*"]

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

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-attach-airbyte-volume"
  description = "IAM policy to allow lambda to attach volume to airbyte instance"

  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}