resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_group_name}-${var.env_name}"
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "prefectnetwork" {
  name                = var.vnet_name
  address_space       = var.vnet_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "prefect_node_subnet" {
  name                 = var.node_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.node_subnet_id
  service_endpoints    = ["Microsoft.Storage"]
}

# resource "azurerm_subnet" "prefect_pod_subnet" {
#   name                 = var.pod_subnet_name
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.prefectnetwork.name
#   address_prefixes     = var.pod_subnet_id
#   service_endpoints    = ["Microsoft.Storage"]
# }