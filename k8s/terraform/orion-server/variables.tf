variable "node_affinity" {
  type = object({
    key      = string
    operator = string
    values   = tuple([string])
  })
  default = null
}
variable "kubernetes_resources_labels" {
  type        = map(any)
  default     = {}
  description = "Labels to apply to all resources"

}

variable "port" {
  default     = 4200
  type        = number
  description = "Port for the service to expose"
}

variable "logging_level" {
  default = "INFO"
}

variable "prefect_version" {
  default = "2.0b2"
}
# app
variable "app_name" {
  default = "orion"
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
  default = "prefect-orion"
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
variable "metadata-labels" {
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

variable "work_queue_id" {
  type    = string
  default = "kubernetes"
}