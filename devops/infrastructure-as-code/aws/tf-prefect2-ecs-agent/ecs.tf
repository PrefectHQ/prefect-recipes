
resource "aws_ecs_cluster" "prefect_agent_cluster" {
  name = "prefect-agent-${var.name}"
}

resource "aws_ecs_cluster_capacity_providers" "prefect_agent_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.prefect_agent_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "prefect_agent_task_definition" {
  family = "prefect-agent-${var.name}"
  cpu    = var.agent_cpu
  memory = var.agent_memory

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name    = "prefect-agent-${var.name}"
      image   = var.agent_image
      command = ["prefect", "agent", "start", "-q", var.agent_queue_name]
      cpu     = var.agent_cpu
      memory  = var.agent_memory
      environment = [
        {
          name  = "PREFECT_API_URL"
          value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}"
        },
        {
          name  = "EXTRA_PIP_PACKAGES"
          value = var.agent_extra_pip_packages
        }
      ]
      secrets = [
        {
          name      = "PREFECT_API_KEY"
          valueFrom = aws_secretsmanager_secret.prefect_api_key.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prefect_agent_log_group.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "prefect-agent-${var.name}"
        }
      }
    }
  ])
  // Execution role allows ECS to create tasks and services
  execution_role_arn = aws_iam_role.prefect_agent_execution_role.arn
  // Task role allows tasks and services to access other AWS resources
  task_role_arn = var.agent_task_role_arn
}

resource "aws_ecs_service" "prefect_agent_service" {
  name          = "prefect-agent-${var.name}"
  cluster       = aws_ecs_cluster.prefect_agent_cluster.id
  desired_count = var.agent_desired_count
  launch_type   = "FARGATE"

  // Public IP required for pulling secrets and images
  // https://aws.amazon.com/premiumsupport/knowledge-center/ecs-unable-to-pull-secrets/
  network_configuration {
    security_groups  = [aws_security_group.prefect_agent.id]
    assign_public_ip = true
    subnets          = var.agent_subnets
  }
  task_definition = aws_ecs_task_definition.prefect_agent_task_definition.arn
}
