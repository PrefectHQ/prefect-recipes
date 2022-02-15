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
      "logs:GetLogEvents"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs_agent" {
  name   = "ecs_agent"
  policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_policy_attachment" "ecs_agent" {
  name       = "ecs_agent"
  roles      = [aws_iam_role.ecs_agent.name]
  policy_arn = aws_iam_policy.ecs_agent.arn
}

resource "aws_iam_role" "ecs_agent" {
  name_prefix = "ecs-agent"

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

resource "aws_iam_role" "ecs_execution" {
  name_prefix = "ecs-execution"

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
  name       = "ecs-execution"
  roles      = [aws_iam_role.ecs_execution.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}