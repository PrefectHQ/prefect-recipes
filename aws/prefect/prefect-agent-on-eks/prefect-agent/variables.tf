variable "api" {
  default = "api.prefect.io"
}
variable "prefect_api_secret_id" {
  description = "Secret ID for Prefect Cloud api key stored in AWS secrets manager"
  type        = string
}
variable "prefect_secret_key" {
  type        = string
  description = "key of aws secrets manager secret for prefect api key"
}
variable "node_affinity" {
  type = object({
    key      = string
    operator = string
    values   = tuple([string])
  })
  default = null
}
variable "logging_level" {
  default = "INFO"
}
variable "prefect_labels" {
  default = "[]"
}
variable "prefect_version" {
  default = "latest"
}
# app
variable "app" {
  default = "prefect-agent"
}
variable "start_args" {
  default = ""
}
variable "image_pull_policy" {
  default = "Always"
}
variable "namespace" {
  default = "prefect"
}
variable "replicas" {
  default = 1
}
variable "service_account_name" {
  default = "prefect-agent"
}
variable "automount_service_account_token" {
  type    = bool
  default = true
}
variable "env_values" {
  type        = map(any)
  description = "a mapping of env vars to their values i.e. {ENV_VAR = 'value'}"
  default     = {}
}
variable "env_secrets" {
  type        = list(any)
  description = "a list of maps of env vars to pull from secrets"
  default     = []
}
variable "secret_volumes" {
  type    = list(any)
  default = []
}
variable "volume_mounts" {
  type    = map(any)
  default = {}
}
# resources
variable "request_mem" {
  default = "100Mi"
}
variable "limit_mem" {
  default = "128Mi"
}
variable "request_cpu" {
  default = "100m"
}
variable "limit_cpu" {
  default = "500m"
}