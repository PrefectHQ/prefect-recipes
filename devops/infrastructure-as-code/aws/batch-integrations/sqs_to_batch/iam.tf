data "aws_iam_policy_document" "sqs_batch" {
  statement {
    sid = "1e5cbbfad0774e8fa6a6a0f9e572b310"

    actions = [
         "batch:SubmitJob",
    ]
    resources = [
      "*",
    ]
  }

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
         "sqs:ReceiveMessage",
         "sqs:DeleteMessage",
         "sqs:GetQueueAttributes",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "sqs_batch" {
    name = "sqs-to-batch-dev"

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


resource "aws_iam_policy" "sqs_batch" {
  name   = "sqs-to-batch-dev"
  policy = data.aws_iam_policy_document.sqs_batch.json
}

resource "aws_iam_policy_attachment" "sqs_batch" {
  name       = "sqs-to-batch-dev"
  roles      = [aws_iam_role.sqs_batch.name]
  policy_arn = aws_iam_policy.sqs_batch.arn
}


# resource "aws_iam_role" "iam_update_batch_table_lambda" {
#     name = "batch-table-update-dev"

#     assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "lambda.amazonaws.com"
#             },
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_role" "iam_retrieve_batch_state_lambda" {
#     name = "get-batchjob-state-dev-api_handler"

#     assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "lambda.amazonaws.com"
#             },
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# EOF
# }


