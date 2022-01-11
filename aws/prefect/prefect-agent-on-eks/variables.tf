variable "cluster_name" {
  type        = string
  description = "a name for the cluster"
}

variable "region" {
  type        = string
  description = "region to deploy resources into"
}

variable "environment" {
  type        = string
  description = "environment of eks deployment"
}

variable "k8s_cluster_version" {
  type        = string
  description = "version number to use for the cluster"
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  description = "additional IAM users to add to the aws-auth configmap"
  default     = []
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  description = "additional IAM Roles to add to the aws-auth configmap"
  default     = []
}

variable "prefect_api_secret_id" {
  type        = string
  description = "AWS secrets manager secret ID for the API key to allow the prefect agent to communicate with Prefect cloud"
  default     = "prefect-api-key"
}

variable "vpc_id" {
  type        = string
  description = "ID for the VPC in which the cluster will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnets in which cluster nodes will be created"
}