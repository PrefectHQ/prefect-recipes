# Required module inputs
variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_identity_oidc_issuer" {
  type        = string
  description = "The OIDC Identity issuer for the cluster"
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account"
}

# Helm
variable "helm_chart_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version" {
  type        = string
  default     = "9.9.0"
  description = "Version of the Helm chart"
}

variable "helm_release_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Helm release name"
}

variable "helm_repo_url" {
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
  description = "Helm repository"
}

# K8s
variable "namespace" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The K8s namespace in which the node-problem-detector service account has been created"
}

variable "k8s_service_account_name" {
  default     = "cluster-autoscaler"
  description = "The k8s cluster-autoscaler service account name"
}

variable "mod_dependency" {
  type        = bool
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://hub.helm.sh/charts/stable/cluster-autoscaler"
}
