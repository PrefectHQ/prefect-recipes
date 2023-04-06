// Variables and Locals
variable "name" {
  description = "Unique name for this EventBridge rule and target"
  type        = string
}

variable "bucket_name" {
  description = "Name of S3 Bucket for event source"
  type        = string
}

variable "object_prefix" {
  description = "Prefix of S3 Object for event source"
  type        = string
  default     = ""
}

variable "invocation_rate_limit_per_second" {
  description = "Maximum number of API calls per second"
  type        = number
  default     = 10
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

variable "prefect_cloud_deployment_id" {
  description = "Prefect Cloud Deployment ID to trigger"
  type        = string
}

locals {
  base_url = "https://api.prefect.cloud/api/accounts/${var.prefect_cloud_account_id}/workspaces/${var.prefect_cloud_workspace_id}"
}
