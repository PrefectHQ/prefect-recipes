terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.prefect.cluster_name
}

provider "kubernetes" {
  host                   = module.prefect.cluster_endpoint
  cluster_ca_certificate = base64decode(module.prefect.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.prefect.cluster_endpoint
    cluster_ca_certificate = base64decode(module.prefect.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
