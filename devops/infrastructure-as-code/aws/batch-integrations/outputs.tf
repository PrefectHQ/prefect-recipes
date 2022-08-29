output "db_id" {
  value = aws_dynamodb_table.dynamo_db_table.id
}

output "db_arn" {
  value = aws_dynamodb_table.dynamo_db_table.arn
}

output "queue_to_batch_arn" {
    value = "${module.sqs_to_batch.queue_to_batch_arn}"
}

output "update_batch_table_arn" {
    value = "${module.sqs_to_batch.update_batch_table_arn}"
}

# output "retrieve_batch_state_arn" {
#     value = "${module.sqs_to_batch.retrieve_batch_state_arn}"
# }

output "sqs_queue_arn" {
    value = "${module.sqs_to_batch.sqs_queue_arn}"
}

output "sqs_batch_iam_role_arn" {
    value = "${module.sqs_to_batch.sqs_batch_iam_role_arn}"
}

output "batch_compute_environment" {
    value = "${data.aws_batch_compute_environment.batch_compute_environment.arn}"
}