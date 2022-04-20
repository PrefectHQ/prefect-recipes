variable "node_affinity" {
  type = object({
    key      = string
    operator = string
    values   = tuple([string])
  })
  default     = null
  description = "Maps of node affinity settings for kubernetes resources"
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
  default     = "INFO"
  description = "Setting for logging level"
}

variable "prefect_version" {
  default     = "2.0b3"
  description = "Prefect image version"
}
# app
variable "app_name" {
  default     = "orion"
  description = "Application name for kubernetes services"
}
variable "start_args" {
  default     = ""
  description = "Arguments to pass to the `prefect orion agent start` command"
}
variable "image_pull_policy" {
  default     = "Always"
  description = "Image pull policy for kubernetes services"
}
variable "namespace" {
  default     = "prefect"
  description = "Select kubernetes namespace in which to deploy"
}
variable "replicas" {
  default     = 1
  description = "Number of kubernetes replicas to deploy"
}
variable "service_account_name" {
  default     = "prefect-orion"
  description = "Kubernetes service account name"
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
  type        = list(any)
  default     = []
  description = "Metadata labels to apply to kubernetes services"
}
variable "volume_mounts" {
  type        = map(any)
  default     = {}
  description = "Volume mounts for kubernetes pods"
}
# resources
variable "orion_server_request_mem" {
  default     = "100Mi"
  description = "Memory request for orion server"
}
variable "orion_server_limit_mem" {
  default     = "128Mi"
  description = "Memory limit for orion server"
}
variable "orion_server_request_cpu" {
  default     = "100m"
  description = "CPU request for orion server"
}
variable "orion_server_limit_cpu" {
  default     = "500m"
  description = "CPU Limit for orion server"
}

variable "prefect_agent_request_mem" {
  default     = "100Mi"
  description = "Memory request for prefect agent"
}
variable "prefect_agent_limit_mem" {
  default     = "128Mi"
  description = "Memory limit for prefect agent"
}
variable "prefect_agent_request_cpu" {
  default     = "100m"
  description = "CPU request for prefect agent"
}
variable "prefect_agent_limit_cpu" {
  default     = "500m"
  description = "CPU limit for prefect agent"
}

variable "work_queue_id" {
  type        = string
  default     = "kubernetes"
  description = "Prefect work queue to subscribe agent to"
}