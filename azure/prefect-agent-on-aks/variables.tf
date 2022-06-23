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
  default     = ["10.0.0.0/16"]
  description = "IDs of the Vnets that will host the Prefect agent"
}

variable "node_subnet_id" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "IDs of the subnets that will host the aks nodes"
}

variable "pod_subnet_id" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "IDs of the subnets that will host the aks pods"
}

variable "agent_count" {
  type    = number
  default = 3
}

variable "dns_prefix" {
  type    = string
  default = "k8stest"
}

variable "cluster_name" {
  type    = string
  default = "k8stest"
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

# This should be set if you want to add a local IP address to your network rules, to manage storage containers locally
variable "local_ip" {
  type        = list(string)
  #default     = null
  description = "A list of public IP addresses you wish to add to network rules for access"
  default   = ["131.226.33.86"]
}

# Storage Accounts must have a globally unique name
variable "storage_account_name" {
  default = "prefectaks"
}
