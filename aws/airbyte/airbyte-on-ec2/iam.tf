resource "aws_iam_instance_profile" "instance_profile" {
  name = "airbyte-instance-profile-${data.aws_region.current.id}"
  role = aws_iam_role.airbyte_role.name
}

resource "aws_iam_role" "airbyte_role" {
  name               = "airbyte-role-${data.aws_region.current.id}"
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

resource "aws_iam_policy" "airbyte_policy" {
  name        = "ec2-airbyte-policy-${data.aws_region.current.id}"
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
