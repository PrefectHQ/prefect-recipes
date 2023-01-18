output "prefect_agent_service_id" {
  value = aws_ecs_service.prefect_agent_service.id
}

output "prefect_agent_execution_role_arn" {
  value = aws_iam_role.prefect_agent_execution_role.arn
}

output "prefect_agent_task_role_arn" {
  value = coalesce(var.agent_task_role_arn, aws_iam_role.prefect_agent_task_role[0].arn)
}

output "prefect_agent_security_group" {
  value = aws_security_group.prefect_agent.id
}

output "prefect_agent_cluster_name" {
  value = aws_ecs_cluster.prefect_agent_cluster.name
}