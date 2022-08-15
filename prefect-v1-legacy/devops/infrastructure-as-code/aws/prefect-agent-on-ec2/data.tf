data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_secretsmanager_secret" "prefect" {
  name = var.prefect_api_key_secret_name
}

locals {
  image_pulling = var.disable_image_pulling ? "--no-pull" : ""
  flow_logs     = var.enable_local_flow_logs ? "--show-flow-logs" : ""
  config_id     = var.agent_automation_config != "" ? "--agent-config-id ${var.agent_automation_config}" : ""
}