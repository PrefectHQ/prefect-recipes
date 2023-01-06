variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_node_min_size" {
  description = "Minimum number of nodes in cluster"
  default     = 1
  type        = number
}

variable "cluster_node_max_size" {
  description = "Maximum number of nodes in cluster"
  default     = 10
  type        = number
}

variable "cluster_node_instance_type" {
  description = "Instance type for nodes in cluster"
  default     = "m5.large"
  type        = string
}

variable "cluster_node_capacity_type" {
  description = "Capacity type for nodes in cluster"
  default     = "SPOT"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs to place cluster in"
  type        = list(string)
}

variable "cluster_tags" {
  description = "Tags to associate with cluster resources"
  default     = {}
  type        = map(any)
}

variable "cluster_vpc_id" {
  description = "ID of VPC to place cluster in"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  default     = "1.24"
  type        = string
}

variable "prefect_agent_count" {
  description = "Number of Prefect agents to run in the cluster"
  default     = 1
  type        = number
}

variable "prefect_agent_work_queue" {
  description = "Name of Prefect work queue that agents will subscribe to"
  default     = "default"
  type        = string
}

variable "prefect_agent_image_repository" {
  description = "Image repository to use for the agent"
  default     = "prefecthq/prefect"
  type        = string
}

variable "prefect_agent_image_tag" {
  description = "Tag of image to use for the agent"
  default     = "2-latest"
  type        = string
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