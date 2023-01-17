variable "agent_cpu" {
  description = "CPU units to allocate to the agent"
  default     = 1024
  type        = number
}

variable "agent_desired_count" {
  description = "Number of agents to run"
  default     = 1
  type        = number
}

variable "agent_extra_pip_packages" {
  description = "Packages to install on the agent assuming image is based on prefecthq/prefect"
  default     = "prefect-aws s3fs"
  type        = string
}

variable "agent_image" {
  description = "Container image for the agent. This could be the name of an image in a public repo or an ECR ARN"
  default     = "prefecthq/prefect:2-python3.10"
  type        = string
}

variable "agent_log_retention_in_days" {
  description = "Number of days to retain agent logs for"
  default     = 30
  type        = number
}

variable "agent_memory" {
  description = "Memory units to allocate to the agent"
  default     = 2048
  type        = number
}

variable "agent_queue_name" {
  description = "Prefect queue that the agent should listen to"
  default     = "default"
  type        = string
}

variable "agent_subnets" {
  description = "Subnets to place the agent in"
  type        = list(string)
}

variable "name" {
  description = "Unique name for this agent deployment"
  type        = string
}

variable "prefect_account_id" {
  description = "Prefect cloud account ID"
  type        = string
}

variable "prefect_workspace_id" {
  description = "Prefect cloud workspace ID"
  type        = string
}

variable "prefect_api_key" {
  description = "Prefect cloud API key"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID in which to create all resources"
  type        = string
}
