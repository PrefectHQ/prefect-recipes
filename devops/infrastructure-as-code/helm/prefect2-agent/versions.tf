terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
  required_version = "~> 1"
}

provider "helm" {
  kubernetes {
    # example entries
    # host     = "https://cluster_endpoint:port"

    # client_certificate     = file("~/.kube/client-cert.pem")
    # client_key             = file("~/.kube/client-key.pem")
    # cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")

    # or use kube config
    # config_path = "~/.kube/config"
    # config_context = "prd"
  }
}
provider "kubernetes" {
  # example entries
  # host     = "https://cluster_endpoint:port"

  # client_certificate     = file("~/.kube/client-cert.pem")
  # client_key             = file("~/.kube/client-key.pem")
  # cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")

  # or use kube config
  # config_path = "~/.kube/config"
  # config_context = "prd"
}
