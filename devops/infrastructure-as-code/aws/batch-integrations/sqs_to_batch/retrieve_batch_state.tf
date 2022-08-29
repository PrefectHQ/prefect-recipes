# resource "aws_lambda_function" "get_batchjob_state" {
#     description = ""
#     function_name = "get-batchjob-state-dev"
#     handler = "app.app"
#     architectures = [
#         "x86_64"
#     ]

#     filename = "./sqs_to_batch/retrieve_batch_state/deployment.zip"
#     memory_size = 128
#     role = "${aws_iam_role.get_batchjob_state.arn}"
#     runtime = "python3.9"
#     timeout = 60
#     tracing_config {
#         mode = "PassThrough"
#     }
# }
