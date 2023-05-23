// Connections & Rules
resource "aws_cloudwatch_event_connection" "prefect_cloud_connection" {
  name               = "prefect-cloud-connection-${var.name}"
  description        = "Prefect Cloud connection using API key for ${var.name}"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = "Bearer ${var.prefect_cloud_api_key}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "s3_object_created" {
  name        = "s3-object-created-rule-${var.name}"
  description = "Object creation events for prefix '${var.object_prefix}' in bucket '${var.bucket_name}' for ${var.name}"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["${var.bucket_name}"]
      }
      object = {
        key = [{
          prefix = "${var.object_prefix}"
        }]
      }
    }
  })
}

// Prefect Cloud deployment target
resource "aws_cloudwatch_event_api_destination" "prefect_cloud_deployment_destination" {
  name                             = "prefect-cloud-deployment-destination-${var.name}"
  description                      = "Create a run of deployment ${var.prefect_cloud_deployment_id} for ${var.name}"
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
    "detail": <detail>
  }
}
EOF
  }
}
