resource "kubernetes_secret_v1" "prefect_api_key" {
  metadata {
    name      = "prefect-api-key"
    namespace = kubernetes_namespace_v1.prefect.metadata[0].name
    labels = {
      "app"                          = "prefect"
      "app.kubernetes.io/name"       = "prefect"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    key = var.prefect_cloud_api_key
  }
}
