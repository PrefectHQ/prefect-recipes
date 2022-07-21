resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}-${var.env_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = var.nodepool_name
    node_count     = var.agent_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.prefect_node_subnet.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }
}