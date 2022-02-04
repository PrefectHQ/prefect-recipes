variable "instance_type" {
  type        = string
  description = "AWS instance type"
  default     = "t3.medium"
}
variable "ami_id" {
  type        = string
  description = "ami to launch the ec2 instance from, windows images not supported"
  default     = ""
}
variable "key_name" {
  type        = string
  description = "private pem key to apply to the prefect instances"
  default     = null
}
variable "environment" {
  type        = string
  description = "SDLC stage"
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the Prefect agent into"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets that will host the Prefect agent EC2 instance"
}
variable "min_capacity" {
  type        = number
  description = "minimum number of Prefect agents to be running at any given time"
  default     = 1
}
variable "max_capacity" {
  type        = number
  description = "maximum number of prefect agents to be running at any given time"
  default     = 1
}
variable "desired_capacity" {
  type        = number
  description = "desired number of prefect agents to be running at any given time"
  default     = 1
}
variable "linux_type" {
  type        = string
  description = "type of linux instance"
  default     = "linux_amd64"
}
variable "prefect_api_key_secret_name" {
  type        = string
  description = "id of aws secrets manager secret for prefect api key"
  default     = "prefect-api-key" #tfsec:ignore:general-secrets-no-plaintext-exposure
}
variable "prefect_secret_key" {
  type        = string
  description = "key of aws secrets manager secret for prefect api key"
  default     = "key" #tfsec:ignore:general-secrets-no-plaintext-exposure
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
variable "agent_automation_config" {
  type        = string
  description = "config id to apply to the prefect agent to enable cloud automations"
  default     = ""
}
variable "disable_image_pulling" {
  type        = string
  description = "disables the prefect agents ability to pull non-local images"
  default     = false
}
variable "enable_local_flow_logs" {
  type        = bool
  description = "enables flow logs to output locally on the agent"
  default     = false
}
variable "custom_tags" {
  description = "custom tags which can be passed on to the AWS resources. they should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}