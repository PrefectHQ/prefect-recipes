module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Networking settings
  vpc_id     = var.cluster_vpc_id
  subnet_ids = var.cluster_subnet_ids
  # Control plane access settings
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = true

  # https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1266937679
  create_aws_auth_configmap = var.cluster_create_aws_auth_configmap
  manage_aws_auth_configmap = var.cluster_manage_aws_auth_configmap
  aws_auth_accounts         = var.cluster_aws_auth_accounts == null ? [var.account_id] : var.cluster_aws_auth_accounts
  aws_auth_roles            = var.cluster_aws_auth_roles
  aws_auth_users            = var.cluster_aws_auth_users

  # Use IAM Roles for Service Accounts (like GKE Workload Identity)
  enable_irsa = true

  eks_managed_node_groups = var.cluster_eks_managed_node_groups

  cluster_addons = var.cluster_addons

  tags = merge(
    {
      cluster_name = var.cluster_name
    },
    var.cluster_tags
  )
}
