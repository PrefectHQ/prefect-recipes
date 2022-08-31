output "queue_to_batch_arn" {
  value = aws_lambda_function.sqs_to_batch.arn
}

output "update_batch_table_arn" {
  value = aws_lambda_function.batch_table_update.arn
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.SQSQueue.arn
}

output "sqs_batch_iam_role_arn" {
  value = aws_iam_role.sqs_batch.arn
}

output "retrieve_batch_state_arn" {
  value = aws_lambda_function.retrieve_batch_state.arn
}

output "retrieve_batch_state_url" {
  value = "${aws_api_gateway_deployment.retrieve_batch_state.invoke_url}${aws_api_gateway_stage.retrieve_batch_state.stage_name}/"
}