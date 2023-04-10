resource "kubernetes_namespace_v1" "prefect" {
  metadata {
    name = var.prefect_namespace
    labels = {
      "app"                          = "prefect"
      "app.kubernetes.io/name"       = "prefect"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}
