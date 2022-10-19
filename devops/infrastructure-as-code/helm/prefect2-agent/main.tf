resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "api_key" {
  count = var.api_key != null ? 1 : 0
  metadata {
    name      = var.api_key_secret.secret_name
    namespace = var.namespace
  }

  data = {
    (var.api_key_secret.secret_key) = var.api_key
  }
}
