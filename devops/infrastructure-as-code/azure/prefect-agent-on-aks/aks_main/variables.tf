variable "resource_group_name" {
  type        = string
  default     = "prefectAKS"
  description = "Prefix of the resource group name"
}

variable "env_name" {
  type        = string
  default     = "dev"
  description = ""
}

variable "resource_group_location" {
  type        = string
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
  # Cannot overlap 10.0.0.0/16 which is the default AKS service cidr
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

variable "cluster_name" {
  type        = string
  default     = "k8stest"
  description = ""
}

variable "agent_count" {
  type        = number
  default     = 2
  description = "Number of AKS nodes to create"
}

variable "dns_prefix" {
  type        = string
  default     = "k8stest"
  description = ""
}

variable "nodepool_name" {
  type        = string
  default     = "default"
  description = ""
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Node size for provisioning nodepools"
}

variable "local_ip" {
  type        = list(string)
  default     = ["123.234.111.222"]
  description = "A list of public IP addresses you wish to add to network rules for access"
}

variable "storage_account_name" {
  type        = string
  default     = "prefectaks"
  description = "Storage accounts must be globally unique, appended with randomized string"
}

variable "container_name" {
  type        = string
  default     = "prefect-logs"
  description = "Name of the container created in the storage account"
}

# variable "aks_service_cidr" {
#     type = number
#     default = "10.1.0.0/16"
#     description = "AKS creates a default service CIDR at 10.0.0.0/16 which conflicts."
# }

# variable "ssh_public_key" {
#   type    = string
#   default = "~/.ssh/id_rsa.pub"
#   description = ""
# }