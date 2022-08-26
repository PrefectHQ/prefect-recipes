output "queue_to_batch_arn" {
  value = aws_lambda_function.sqs_to_batch.arn
}

output "update_batch_table_arn" {
  value = aws_lambda_function.batch_table_update.arn
}

output "retrieve_batch_state_arn" {
  value = aws_lambda_function.get_batchjob_state.arn
}