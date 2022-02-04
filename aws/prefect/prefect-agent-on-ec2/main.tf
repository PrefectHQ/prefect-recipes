resource "aws_launch_template" "prefect" {
  name_prefix = "prefect-agent"
  description = "launches a prefect agent on a specified image"

  image_id      = var.ami_id == "" ? data.aws_ami.amazon_linux_2.id : var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name != null ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      Name        = "prefect-agent"
      managed-by  = "terraform"
      environment = var.environment
    }, var.custom_tags)
  }

  user_data = base64encode(templatefile("${path.module}/prefect-agent.sh",
    {
      region              = data.aws_region.current.name
      linux_type          = var.linux_type
      prefect_secret_name = var.prefect_api_key_secret_name
      prefect_secret_key  = var.prefect_secret_key
      prefect_api_address = var.prefect_api_address
      prefect_labels      = var.prefect_labels
      image_pulling       = local.image_pulling
      flow_logs           = local.flow_logs
      config_id           = local.config_id
    }
  ))
}

resource "aws_autoscaling_group" "prefect" {
  name_prefix               = "prefect-agent"
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids

  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"]

  lifecycle {
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.prefect.id
    version = "$Latest"
  }
}

resource "aws_security_group" "sg" {
  name_prefix = "prefect-agent"
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