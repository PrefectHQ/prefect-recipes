// Connections & Rules
resource "aws_cloudwatch_event_connection" "prefect_cloud_connection" {
  name               = "prefect-cloud-connection"
  description        = "Prefect Cloud connection using API key"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${var.prefect_cloud_api_key}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "s3-object-created-in-${var.bucket_name}"
  description = "Capture S3 object creation events for bucket '${var.bucket_name}'"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["${var.bucket_name}"]
      }
    }
  })
}

// Prefect Cloud event target
// TODO: Split into submodule
resource "aws_cloudwatch_event_api_destination" "prefect_cloud_event_destination" {
  name                             = "prefect-cloud-event"
  description                      = "Create a Prefect Cloud event"
  invocation_endpoint              = "${local.base_url}/events"
  http_method                      = "POST"
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  connection_arn                   = aws_cloudwatch_event_connection.prefect_cloud_connection.arn
}

resource "aws_cloudwatch_event_target" "prefect_cloud_event_target" {
  arn      = aws_cloudwatch_event_api_destination.prefect_cloud_event_destination.arn
  rule     = aws_cloudwatch_event_rule.s3_object_created.id
  role_arn = aws_iam_role.cloudwatch_event_role.arn

  input_transformer {
    input_paths = {
      id     = "$.id",
      time   = "$.time",
      region = "$.region",
      bucket = "$.detail.bucket.name",
      key    = "$.detail.object.key",
      size   = "$.detail.object.size",
    }
    input_template = <<EOF
[{
  "event": "aws.s3.object.created",
  "id": "<id>",
  "occurred": "<time>",
  "resource": {
    "prefect.resource.id": "aws.s3.object.<bucket>.<key>",
    "aws.region": "<region>",
    "aws.s3.bucket.name": "<bucket>",
    "aws.s3.object.key": "<key>",
    "aws.s3.object.size": "<size>"
  }
}]
EOF
  }
}

// Prefect Cloud deployment target
// TODO: Split into submodule
resource "aws_cloudwatch_event_api_destination" "prefect_cloud_deployment_destination" {
  name                             = "prefect-cloud-deployment"
  description                      = "Create a Prefect Cloud Flow Run"
  invocation_endpoint              = "${local.base_url}/deployments/${var.prefect_cloud_deployment_id}/create_flow_run"
  http_method                      = "POST"
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  connection_arn                   = aws_cloudwatch_event_connection.prefect_cloud_connection.arn
}

resource "aws_cloudwatch_event_target" "prefect_cloud_deployment_target" {
  arn      = aws_cloudwatch_event_api_destination.prefect_cloud_deployment_destination.arn
  rule     = aws_cloudwatch_event_rule.s3_object_created.id
  role_arn = aws_iam_role.cloudwatch_event_role.arn

  input_transformer {
    input_paths = {
      detail = "$.detail",
    }
    input_template = <<EOF
{
  "parameters": {
    "name": <detail>
  }
}
EOF
  }
}
