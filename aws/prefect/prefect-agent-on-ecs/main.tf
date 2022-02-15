resource "aws_ecs_cluster" "prefect" {
  name = "prefect"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.prefect.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "prefect" {
  name_prefix = "prefect-ecs-cluster-"
}

resource "aws_ecs_service" "prefect" {
  name             = "prefect-agent"
  cluster          = aws_ecs_cluster.prefect.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  task_definition  = aws_ecs_task_definition.prefect.arn
  desired_count    = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "prefect" {
  family = "prefect-agent"
  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_agent.arn

  container_definitions = templatefile("${path.module}/prefect-agent.json.tftpl",
    {
      region              = data.aws_region.current.name
      prefect_api_key     = var.prefect_api_key
      prefect_api_address = var.prefect_api_address
      prefect_labels      = var.prefect_labels
      logging_level       = var.logging_level
      log_group           = aws_cloudwatch_log_group.prefect_agent.name
    }
  )
}

resource "aws_cloudwatch_log_group" "prefect_agent" {
  name_prefix = "prefect-ecs-agent-"
}

resource "aws_security_group" "sg" {
  name_prefix = "prefect-agent-"
  description = "allow all outbound traffic from the prefect agent"
  vpc_id      = var.vpc_id

  tags = merge({
    Name         = "prefect-agent"
    "managed-by" = "terraform"
  }, var.custom_tags)
}

resource "aws_security_group_rule" "prefect_egress" {
  description       = "allow all egress traffic to the internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  security_group_id = aws_security_group.sg.id
}