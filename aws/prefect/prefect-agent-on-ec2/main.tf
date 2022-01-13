resource "aws_launch_template" "prefect" {
  name = "prefect"

  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "prefect-agent"
      managed-by  = "terraform"
      environment = var.environment
    }
  }

  user_data = base64encode(templatefile("${path.module}/prefect-agent.sh",
    {
      region              = data.aws_region.current.name
      linux_type          = var.linux_type
      prefect_secret_name = var.prefect_secret_name
      prefect_secret_key  = var.prefect_secret_key
    }
  ))
}

resource "aws_autoscaling_group" "prefect" {
  name                      = "prefect-asg"
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
  name   = "prefect-agent"
  vpc_id = var.vpc_id

  egress = [
    {
      from_port        = "0"
      to_port          = "0"
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow all outbound"
      security_groups  = null
      self             = null
      prefix_list_ids  = null
      ipv6_cidr_blocks = null
    }
  ]

  tags = {
    Name         = "prefect-agent"
    "managed-by" = "terraform"
  }
}