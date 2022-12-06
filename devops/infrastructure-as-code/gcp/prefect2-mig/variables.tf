variable "project_id" {
  type        = string
  description = "google cloud project ID"
}
variable "region" {
  type        = string
  description = "region to deploy the resources to"
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
variable "name_prefix" {
  type        = string
  description = "Prefix for the instance name"
  default     = "prefect-agent"
}
variable "machine_type" {
  type        = string
  description = "GCP Machine type to be used for the Prefect Agent VM"
  default     = "n2d-highcpu-2"
}
variable "disk_type" {
  type        = string
  description = "Disk type to be used by the Prefect Agent VM"
  default     = "pd-standard"
}
variable "disk_size" {
  type        = string
  description = "Size of the Prefect Agent VM disk"
  default     = "20"
}
variable "preemptible" {
  description = "prefect cloud account ID"
  default     = false
}
variable "prefect_account_id" {
  type        = string
  description = "prefect cloud account ID"
}
variable "prefect_workspace_id" {
  type        = string
  description = "prefect cloud workspace ID"
}
variable "prefect_api_key" {
  type        = string
  description = "prefect cloud api key"
  sensitive   = true
}
variable "work_queue" {
  type        = string
  description = "prefect cloud work queue name"
}
