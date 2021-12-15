output "deployment_name" { value = kubernetes_deployment.deployment.metadata[0].name }
output "namespace" { value = kubernetes_deployment.deployment.metadata[0].namespace }

output "version" {
  value = var.prefect_version
}
