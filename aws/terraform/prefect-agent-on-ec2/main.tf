resource "aws_launch_configuration" "prefect" {
  name_prefix   = "prefect-agent-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.instance_profile.id
  enable_monitoring    = true

  security_groups = [aws_security_group.sg.id]

  user_data = file("${path.module}/prefect-agent.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "prefect" {
  name                      = "prefect-asg"
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.prefect.name
  vpc_zone_identifier       = var.private_subnet_ids

  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"]

  tag {
    key                 = "Name"
    value               = "prefect-agent"
    propagate_at_launch = true
  }
  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }
  tag {
    key                 = "managed-by"
    value               = "terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
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