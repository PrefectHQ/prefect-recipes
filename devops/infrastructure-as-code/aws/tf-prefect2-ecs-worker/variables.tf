variable "worker_cpu" {
  description = "CPU units to allocate to the worker"
  default     = 1024
  type        = number
}

variable "worker_desired_count" {
  description = "Number of workers to run"
  default     = 1
  type        = number
}

variable "worker_extra_pip_packages" {
  description = "Packages to install on the worker assuming image is based on prefecthq/prefect"
  default     = "prefect-aws s3fs"
  type        = string
}

variable "worker_image" {
  description = "Container image for the worker. This could be the name of an image in a public repo or an ECR ARN"
  default     = "prefecthq/prefect:2-python3.10"
  type        = string
}

variable "worker_log_retention_in_days" {
  description = "Number of days to retain worker logs for"
  default     = 30
  type        = number
}

variable "worker_memory" {
  description = "Memory units to allocate to the worker"
  default     = 2048
  type        = number
}

variable "worker_work_pool_name" {
  description = "Work pool that the worker should listen to"
  type        = string
}

variable "worker_subnets" {
  description = "Subnets to place the worker in"
  type        = list(string)
}

variable "worker_task_role_arn" {
  description = "Optional task role ARN to pass to the worker. If not defined, a task role will be created"
  default     = null
  type        = string
}

variable "name" {
  description = "Unique name for this worker deployment"
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

variable "secrets_manager_recovery_in_days" {
  type        = number
  default     = 30
  description = "Deletion delay for AWS Secrets Manager upon resource destruction"
}

variable "worker_type" {
  type        = string
  default     = "ecs"
  description = "Prefect Worker type that gets passed into the prefect worker start command"
}
