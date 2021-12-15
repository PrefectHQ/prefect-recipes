variable "api" { default = "api.prefect.io" }
variable "api_key" {
  description = "Prefect Cloud api key or (deprecated) token"
}
variable "create_namespace" { default = true }
variable "use_existing_role" { default = false }
variable "use_existing_secret" { default = false }
variable "api_key_secret_name" { default = "prefect-cloud-api-key" }
variable "node_affinity" {
  type = object({
    key      = string
    operator = string
    values   = tuple([string])
  })
  default = null
}
variable "logging_level" { default = "INFO" }
variable "prefect_labels" { default = "[]" }
variable "prefect_version" { default = "latest" }

# app
variable "app" { default = "prefect-agent" }
variable "start_args" { default = "" }
variable "image_pull_policy" { default = "Always" }
variable "namespace" { default = "default" }
variable "replicas" { default = 1 }
# if supplied, a workload identity annotation will be placed
# on agent's serviceaccount--workload identity must also be
# enabled on the cluster and authorized on the GCP serviceaccount
variable "service_account_annotations" {
  default = null
  type    = map(any)
}

variable "service_account_name" { default = null }
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
variable "request_mem" { default = "100Mi" }
variable "limit_mem" { default = "128Mi" }
variable "request_cpu" { default = "100m" }
variable "limit_cpu" { default = "500m" }

#k8s auth
variable "kube_host" {}
variable "kube_cacert" {}
