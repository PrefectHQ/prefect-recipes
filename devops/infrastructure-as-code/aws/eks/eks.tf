// Define EKS cluster
// https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.cluster_vpc_id
  subnet_ids = var.cluster_subnet_ids

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size     = var.cluster_node_min_size
      max_size     = var.cluster_node_max_size
      desired_size = var.cluster_node_min_size

      instance_types = [var.cluster_node_instance_type]
      capacity_type  = var.cluster_node_capacity_type
    }
  }

  tags = var.cluster_tags
}
