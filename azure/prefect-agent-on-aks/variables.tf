variable "resource_group_name" {
  default     = "prefectAKS"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "vnet_name" {
  type        = string
  default     = "prefectVnet"
  description = "Name of the Vnet to create"
}

variable "node_subnet_name" {
  type        = string
  default     = "aks_node_subnet"
  description = "Name of the subnet to create"
}

variable "pod_subnet_name" {
  type        = string
  default     = "aks_pod_subnet"
  description = "Name of the subnet to create"
}

variable "vnet_id" {
  type        = list(string)
  default     = ["10.1.0.0/16"]
  description = "IDs of the Vnets that will host the Prefect agent"
}

variable "node_subnet_id" {
  type        = list(string)
  default     = ["10.1.0.0/22"]
  description = "IDs of the subnets that will host the aks nodes"
}

variable "pod_subnet_id" {
  type        = list(string)
  default     = ["10.1.4.0/22"]
  description = "IDs of the subnets that will host the aks pods"
}

# variable "aks_service_cidr" {
#     type = number
#     default = "10.1.0.0/16"
#     description = "AKS creates a default service CIDR at 10.0.0.0/16 which conflicts."
# }

variable "agent_count" {
  type    = number
  default = 2
}

variable "dns_prefix" {
  type    = string
  default = "k8stest"
}

variable "cluster_name" {
  type    = string
  default = "k8stest"
}

variable "env_name" {
  type    = string
  default = "dev"
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "local_ip" {
  type        = list(string)
  description = "A list of public IP addresses you wish to add to network rules for access"
  default     = ["131.226.33.86"]
}

variable "storage_account_name" {
  type = string
  default = "prefectaks"
}

variable "container_name" {
  type = string
  default = "prefect-logs"
}
