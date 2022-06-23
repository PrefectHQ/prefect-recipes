# Create randomized resource group name in your designated region
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_group_name}"
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "prefectnetwork" {
  name                = var.vnet_name
  address_space       = var.vnet_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create the pod subnet in  myVnet
resource "azurerm_subnet" "prefect_pod_subnet" {
  name                 = var.pod_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.pod_subnet_id
  service_endpoints    = ["Microsoft.Storage"]
}

# Create the node subnet in  myVnet
resource "azurerm_subnet" "prefect_node_subnet" {
  name                 = var.node_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.node_subnet_id
  service_endpoints    = ["Microsoft.Storage"]
}

resource "random_id" "storage_container_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "prefect-logs" {
  name                = "${var.storage_account_name}${random_id.storage_container_suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.local_ip
    virtual_network_subnet_ids = [azurerm_subnet.prefect_pod_subnet.id, azurerm_subnet.prefect_node_subnet.id]
  }
}

resource "azurerm_storage_container" "prefect-logs" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.prefect-logs.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}-${var.env_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = var.agent_count
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.prefect_node_subnet.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  tags = {
    Environment = "Development"
  }
}