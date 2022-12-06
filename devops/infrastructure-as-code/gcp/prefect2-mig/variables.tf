variable "project_id" {
  type        = string
  description = "google cloud project ID"
}
variable "region" {
  type        = string
  description = "region to deploy the resources to"
}
variable "env" {
  type        = string
  description = "environment stage to apply to the agent"
}
variable "subnet" {
  type        = string
  description = "subnet to deploy the managed instance group"
}
variable "num_vm" {
  type        = number
  description = "Number of deployed VMs in the managed instance group"
  default     = 1
}
variable "prefect_account_id" {
  type        = string
  description = "Prefect cloud account ID"
}
variable "prefect_workspace_id" {
  type        = string
  description = "Prefect cloud account ID"
}
variable "prefect_api_key" {
  type        = string
  description = "Prefect cloud api key"
  # sensitive = true
}
variable "work_queue" {
  type        = string
  description = "Prefect cloud work queue name"
}
