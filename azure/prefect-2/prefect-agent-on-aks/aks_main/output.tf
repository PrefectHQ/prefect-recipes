output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "storage_name" {
  value = azurerm_storage_account.prefect-logs.name
}

output "container_name" {
  value = azurerm_storage_container.prefect-logs.name
}
