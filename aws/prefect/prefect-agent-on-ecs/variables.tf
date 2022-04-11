variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region in which to create resources"
}

variable "flow_log_group_name" {
  default     = "prefect-flows"
  type        = string
  description = "Name of Cloudwatch Log group for Prefect Flows"

}

variable "flow_log_stream_prefix" {
  default     = "ecs-prefect"
  type        = string
  description = "Prefix for all flow log streams"

}
variable "vpc_id" {
  type        = string
  description = "ID of VPC to deploy the Prefect ECS agent into"
}
variable "subnet_ids" {
  type        = list(string)
  description = "subnet IDs to deploy the Prefect ECS agent into"
}
variable "custom_tags" {
  description = "custom tags which can be passed on to the AWS resources. they should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}
variable "prefect_api_key" {
  type        = string
  description = "Prefect service account API key"
}
variable "prefect_api_address" {
  type        = string
  description = "the api address that the prefect agent queries for pending flow runs"
  default     = "https://api.prefect.io"
}
variable "prefect_labels" {
  type        = string
  description = "labels to apply to the prefect agent" # DESCRIBE EXACT TYPE "['us-east-1']"
  default     = ""
}
variable "logging_level" {
  type        = string
  description = "logging level to apply to the ECS Prefect agent"
  default     = "INFO"
}

variable "cluster_name" {
  type = string

  description = "Name of ECS Cluster in which to create all resources"
  default     = "prefect"
}

variable "prefect_version" {
  type        = string
  default     = "1.2.0"
  description = "Prefect core version for the agent to run"
}
