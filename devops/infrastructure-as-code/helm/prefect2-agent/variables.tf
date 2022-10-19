variable "prefect_cloud_account_id" {
  type        = string
  description = "prefect cloud account ID"
}
variable "prefect_cloud_workspace_id" {
  type        = string
  description = "prefect cloud workspace ID"
}
variable "create_namespace" {
  type = bool
  description = "optionally create the namespace to deploy the chart & agent to"
  default = true
}
variable "namespace" {
  type        = string
  description = "namespace to create & deploy the agent into"
  default     = "prefect"
}
variable "api_key" {
  type        = string
  sensitive   = true
  description = "provide prefect cloud API key here to create a secret within k8s, otherwise provide the name of an existing secret"
  default     = null
}
variable "api_key_secret" {
  type = object({
    secret_name = string
    secret_key  = string
  })
  description = "name & key of k8s secret that contains the prefect cloud API key"
  default = {
    secret_name = "prefect-api-key"
    secret_key  = "key"
  }
}
