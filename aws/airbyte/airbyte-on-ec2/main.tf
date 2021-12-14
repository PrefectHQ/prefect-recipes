# download configs
data "aws_region" "current" {}

resource "aws_instance" "airbyte" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.sg.id]

  root_block_device {
    volume_size = var.volume_size
  }

  user_data = templatefile("${path.module}/airbyte-install.sh",
    {
      region     = data.aws_region.current.name
      linux_type = var.linux_type
    }
  )

  key_name = var.key_name

  tags = {
    Name         = "airbyte"
    "managed-by" = "terraform"
  }
}

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