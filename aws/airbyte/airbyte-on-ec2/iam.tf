resource "aws_iam_instance_profile" "airbyte" {
  name_prefix = "airbyte"
  role        = aws_iam_role.airbyte.name
}

resource "aws_iam_role" "airbyte" {
  name_prefix        = "airbyte"
  assume_role_policy = data.aws_iam_policy_document.airbyte_assume_policy.json
}

data "aws_iam_policy_document" "airbyte_assume_policy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "airbyte" { #tfsec:ignore:aws-iam-no-policy-wildcards
  version = "2012-10-17"

  statement {
    sid = "allowlogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "airbyte" {
  name_prefix = "airbyte"
  description = "iam policy to allow airbyte instance to ship logs to cwl and push data to s3"
  policy      = data.aws_iam_policy_document.airbyte.json
}

resource "aws_iam_role_policy_attachment" "airbyte" {
  name_prefix = "airbyte"
  role        = aws_iam_role.airbyte.name
  policy_arn  = aws_iam_policy.airbyte.arn
}

resource "aws_iam_policy_attachment" "ssm" {
  name_prefix = "ssm"
  roles       = [aws_iam_role.airbyte.id]
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
