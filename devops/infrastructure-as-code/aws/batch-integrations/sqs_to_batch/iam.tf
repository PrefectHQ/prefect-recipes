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


