data "aws_iam_policy_document" "ecs_agent" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DeleteSecurityGroup",
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeClusters",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListAccountSettings",
      "ecs:ListClusters",
      "ecs:ListTaskDefinitions",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "ecs:StopTask",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "iam:PassRole",
      "s3:*"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs_agent" {
  name   = "prefect-ecs-agent"
  policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_policy_attachment" "ecs_agent" {
  name       = "prefect-ecs-agent"
  roles      = [aws_iam_role.ecs_agent.name]
  policy_arn = aws_iam_policy.ecs_agent.arn
}

resource "aws_iam_role" "ecs_agent" {
  name_prefix = "prefect-ecs-agent"

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
}

# Execution role
resource "aws_iam_role" "ecs_execution" {
  name_prefix = "prefect-ecs-execution"

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
}

resource "aws_iam_policy_attachment" "ecs_execution" {
  name       = "prefect-ecs-execution"
  roles      = [aws_iam_role.ecs_execution.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_execution_additional" {
  name   = "prefect-ecs-execution-additional"
  policy = data.aws_iam_policy_document.ecs_execution_additional.json
}

resource "aws_iam_policy_attachment" "ecs_execution_additional" {
  name       = "prefect-ecs-execution-additional"
  roles      = [aws_iam_role.ecs_execution.name]
  policy_arn = aws_iam_policy.ecs_execution_additional.arn
}



data "aws_iam_policy_document" "ecs_execution_additional" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = [
      "*",
    ]
  }
}

### Task Role

data "aws_iam_policy_document" "prefect_task_role" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "prefect_task_role" {
  name   = "prefect-ecs-task"
  policy = data.aws_iam_policy_document.prefect_task_role.json
}

resource "aws_iam_policy_attachment" "prefect_task_role" {
  name       = "prefect-ecs-task"
  roles      = [aws_iam_role.prefect_task_role.name]
  policy_arn = aws_iam_policy.prefect_task_role.arn
}

resource "aws_iam_role" "prefect_task_role" {
  name_prefix = "prefect-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
