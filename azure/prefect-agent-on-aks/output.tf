output "id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}