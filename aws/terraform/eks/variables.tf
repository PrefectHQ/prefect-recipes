variable "cluster_name" {
  description = "a name for the cluster"
  type        = string
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
  description = "version number to use for the cluster"
  type        = string
}

variable "map_users" {
  description = "additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM Roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "prefect_api_secret_id" {
  type        = string
  description = "API key to allow the prefect agent to communicate with Prefect cloud"
  default     = "prefect_api_key"
}

variable "vpc_id" {
    type = string
    description = "ID for the VPC in which the cluster will be created"
}

variable "private_subnets" {
    type = list
    description = "Private subnets in which cluster nodes will be created"
}