module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.20.0"
  cluster_name    = var.cluster_name
  cluster_version = var.k8s_cluster_version
  enable_irsa     = true

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  node_groups = {
    config = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        Environment = var.environment
        base_node   = "yes"
      }
      additional_tags = {
        managed-by = "terraform"
      }
    }

    standard = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      k8s_labels = {
        Environment = var.environment
      }
      additional_tags = {
        managed-by = "terraform"
      }
    }
  }

  map_users = var.map_users
  map_roles = var.map_roles

  tags = {
    Environment = var.environment
    Service     = "prefect",
    managed-by  = "terraform"
  }
}