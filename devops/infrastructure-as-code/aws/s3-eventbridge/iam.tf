resource "aws_iam_role" "cloudwatch_event_role" {
  name = "cloudwatch-event-role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "cloudwatch-event-policy-${var.name}"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "events:InvokeApiDestination"
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}