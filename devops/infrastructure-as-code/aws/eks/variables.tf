variable "account_id" {
  description = "AWS Account ID in which to deploy the cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "prefect"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges from which to accept connections to the control plane"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_create_aws_auth_configmap" {
  description = "Create the aws_auth ConfigMap (see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1266937679)"
  type        = bool
  default     = false
}

variable "cluster_manage_aws_auth_configmap" {
  description = "Manage the aws_auth ConfigMap (see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1266937679)"
  type        = bool
  default     = true
}

variable "cluster_aws_auth_accounts" {
  description = "Setting for aws_auth_accounts (by default, will be the account_id)"
  type        = list(any)
  default     = null
}

variable "cluster_aws_auth_roles" {
  description = "Setting for aws_auth_roles (by default, will be empty)"
  type        = list(any)
  default     = []
}

variable "cluster_aws_auth_users" {
  description = "Setting for aws_auth_users (by default, will be empty)"
  type        = list(any)
  default     = []
}

variable "cluster_eks_managed_node_groups" {
  description = "Cluster EKS managed node groups"
  type        = any
  default = {
    default = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      instance_types = [
        "m6a.large",
      ]

      capacity_type = "SPOT"
    }
  }
}

variable "cluster_addons" {
  description = "Cluster addons to install"
  type        = any
  default = {
    "aws-ebs-csi-driver" = {
      most_recent = true
    }
    "coredns" = {
      most_recent = true
    }
    "kube-proxy" = {
      most_recent = true
    }
    "vpc-cni" = {
      most_recent = true
    }
  }
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs to place cluster in"
  type        = list(string)
}

variable "cluster_tags" {
  description = "Tags to associate with cluster resources (a default cluster_name tag will apply)"
  type        = map(any)
  default     = {}
}

variable "cluster_vpc_id" {
  description = "ID of VPC to place cluster in"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.25"
}

variable "prefect_namespace" {
  description = "Kubernetes namespace to create"
  type        = string
  default     = "prefect"
}

variable "prefect_cloud_api_url" {
  description = "Prefect Cloud API URL prefix (defaults to the value from the Helm Chart)"
  type        = string
  default     = ""
}

variable "prefect_cloud_account_id" {
  description = "Prefect Cloud account ID"
  type        = string
}

variable "prefect_cloud_workspace_id" {
  description = "Prefect Cloud workspace ID"
  type        = string
}

variable "prefect_cloud_api_key" {
  description = "Prefect Cloud API key"
  type        = string
  sensitive   = true
}

variable "prefect_agent_replicas" {
  description = "Number of Prefect agent replicas to run in the cluster"
  type        = number
  default     = 1
}

variable "prefect_agent_chart_version" {
  description = "Prefect agent Helm chart version to install (defaults to the latest version)"
  type        = string
  default     = ""
}

variable "prefect_agent_image_repository" {
  description = "Image repository to use for the agent (defaults to the value included in the Helm chart)"
  type        = string
  default     = ""
}

variable "prefect_agent_image_tag" {
  description = "Tag of image to use for the agent (defaults to the value included in the Helm chart)"
  type        = string
  default     = ""
}

variable "prefect_agent_work_queues" {
  description = "Name of Prefect work queue that agents will subscribe to"
  type        = list(string)
  default     = ["default"]
}

variable "prefect_worker_replicas" {
  description = "Number of Prefect worker replicas to run in the cluster"
  type        = number
  default     = 0
}

variable "prefect_worker_chart_version" {
  description = "Prefect worker Helm chart version to install (defaults to the latest version)"
  type        = string
  default     = ""
}

variable "prefect_worker_image_repository" {
  description = "Image repository to use for the worker (defaults to the value included in the Helm chart)"
  type        = string
  default     = ""
}

variable "prefect_worker_image_tag" {
  description = "Tag of image to use for the worker (defaults to the value included in the Helm chart)"
  type        = string
  default     = ""
}

variable "prefect_worker_work_pool" {
  description = "Name of Prefect work pool that the worker will subscribe to"
  type        = string
  default     = "default"
}
