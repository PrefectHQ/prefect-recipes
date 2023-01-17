terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

// Region speficied in AWS provider
data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "prefect_api_key" {
  name = "prefect-api-key-${var.name}"
}

resource "aws_secretsmanager_secret_version" "prefect_api_key_version" {
  secret_id     = aws_secretsmanager_secret.prefect_api_key.id
  secret_string = var.prefect_api_key
}

resource "aws_iam_role" "prefect_agent_execution_role" {
  name = "prefect-agent-execution-role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ssm-allow-read-prefect-api-key-${var.name}"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "kms:Decrypt",
            "secretsmanager:GetSecretValue",
            "ssm:GetParameters"
          ]
          Effect = "Allow"
          Resource = [
            aws_secretsmanager_secret.prefect_api_key.arn
          ]
        }
      ]
    })
  }
  // AmazonECSTaskExecutionRolePolicy is an AWS managed role for creating ECS tasks and services
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "prefect_agent_task_role" {
  name = "prefect-agent-task-role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "prefect-agent-allow-ecs-task-${var.name}"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:GetLogEvents",
            "logs:PutLogEvents",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetAuthorizationToken",
            "ecr:GetDownloadUrlForLayer",
            "ecs:DeregisterTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:RunTask"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "prefect_agent_log_group" {
  name              = "prefect-agent-log-group-${var.name}"
  retention_in_days = var.agent_log_retention_in_days
}
