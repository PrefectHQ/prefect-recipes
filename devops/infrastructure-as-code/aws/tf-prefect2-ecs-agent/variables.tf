variable "aws_region" {
  description = "AWS region to place resources in"
  default     = "us-east-1"
  type        = string
}

variable "agent_cpu" {
  description = "CPU units to allocate to agent"
  default     = 1024
  type        = number
}

variable "agent_desired_count" {
  description = "Number of agents to run"
  default     = 1
  type        = number
}

variable "agent_image" {
  description = "Container image for the agent"
  default     = "prefecthq/prefect:2.2.0-python3.10"
  type        = string
}

variable "agent_memory" {
  description = "Memory units to allocate to agent"
  default     = 2048
  type        = number
}

variable "agent_queue_name" {
  description = "Queue that agent should listen to"
  default     = "default"
  type        = string
}

variable "agent_subnets" {
  description = "Subnets to place fargate tasks in"
  type        = list(string)
}

variable "agent_task_role_arn" {
  description = "Optional task role to pass to the agent"
  default = ""
  type = string
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
