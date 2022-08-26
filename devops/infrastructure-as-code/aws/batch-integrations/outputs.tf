output "db_id" {
  value = aws_dynamodb_table.DynamoDBTable.id
}

output "db_arn" {
  value = aws_dynamodb_table.DynamoDBTable.arn
}

output "queue_to_batch_arn" {
    value = "${module.sqs_to_batch.queue_to_batch_arn}"
}

output "update_batch_table_arn" {
    value = "${module.sqs_to_batch.update_batch_table_arn}"
}

output "retrieve_batch_state_arn" {
    value = "${module.sqs_to_batch.retrieve_batch_state_arn}"
}