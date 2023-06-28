output "prefect_worker_service_id" {
  value = aws_ecs_service.prefect_worker_service.id
}

output "prefect_worker_execution_role_arn" {
  value = aws_iam_role.prefect_worker_execution_role.arn
}

output "prefect_worker_task_role_arn" {
  value = var.worker_task_role_arn == null ? aws_iam_role.prefect_worker_task_role[0].arn : var.worker_task_role_arn
}

output "prefect_worker_security_group" {
  value = aws_security_group.prefect_worker.id
}

output "prefect_worker_cluster_name" {
  value = aws_ecs_cluster.prefect_worker_cluster.name
}