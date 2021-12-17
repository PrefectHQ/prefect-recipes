data "aws_region" "current" {}

resource "aws_launch_template" "airbyte" {
  name = "airbyte"

  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = false
      volume_size           = var.volume_size
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name         = "airbyte"
      "managed-by" = "terraform"
    }
  }

  user_data = base64encode(templatefile("${path.module}/airbyte-install.sh",
    {
      region     = data.aws_region.current.name
      linux_type = var.linux_type
    }
  ))
}

resource "aws_autoscaling_group" "airbyte" {
  name                      = "airbyte-asg"
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids

  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity", "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupTotalInstances"]

  tag {
    key                 = "Name"
    value               = "airbyte"
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

  launch_template {
    id      = aws_launch_template.airbyte.id
    version = "$Latest"
  }
}

# resource "aws_instance" "airbyte" {
#   ami                  = var.ami_id
#   instance_type        = var.instance_type
#   iam_instance_profile = aws_iam_instance_profile.instance_profile.name

#   subnet_id       = var.subnet_id
#   security_groups = [aws_security_group.sg.id]

#   root_block_device {
#     volume_size = var.volume_size
#   }

#   user_data = templatefile("${path.module}/airbyte-install.sh",
#     {
#       region     = data.aws_region.current.name
#       linux_type = var.linux_type
#     }
#   )

#   key_name = var.key_name

#   tags = {
#     Name         = "airbyte"
#     "managed-by" = "terraform"
#   }
# }

resource "aws_security_group" "sg" {
  name   = "airbyte-instance"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "airbyte-instance"
    "managed-by" = "terraform"
  }
}