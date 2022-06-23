output "id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "container_name" {
    value = azurerm_storage_container.prefect-logs.name
}

# Do I need to export an access key for configuring Blob storage for Prefect later?
# output "storage_key" {
#     value = azurerm_storage_account.prefect-logs.primary_connection_string
# }

