variable "resource_group_name" {
  default     = "prefectAKS_RG"
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

variable "subnet_name" {
  type        = string
  default     = "prefectSubnet"
  description = "Name of the subnet to create"
}

variable "vnet_id" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "IDs of the Vnets that will host the Prefect agent"
}

variable "subnet_id" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "IDs of the subnets that will host the Prefect agent"
}