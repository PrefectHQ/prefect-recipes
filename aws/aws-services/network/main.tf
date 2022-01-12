data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "${var.vpc_name}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  manage_default_route_table = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60


  tags = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
    ecr = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
      tags         = { Name = "ecr-vpc-endpoint" }
    }
  }
}