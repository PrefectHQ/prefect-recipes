resource "kubernetes_service_account" "agent" {
  count = var.use_existing_role == false ? 1 : 0
  metadata {
    name        = var.service_account_name
    namespace   = local.namespace.metadata[0].name
    annotations = var.service_account_annotations
  }

}

resource "kubernetes_role" "prefect_agent" {
  count = var.use_existing_role == false ? 1 : 0
  metadata {
    name      = "prefect-agent"
    namespace = local.namespace.metadata[0].name
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["*"]
  }
  rule {
    api_groups = [""]
    resources  = ["events", "pods"]
    verbs      = ["*"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs = ["get",
      "list",
      "watch",
      "create",
    "delete", ]
  }
}

resource "kubernetes_role_binding" "prefect_agent" {
  count = var.use_existing_role == false ? 1 : 0
  metadata {
    name      = "prefect-agent"
    namespace = local.namespace.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.prefect_agent[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.service_account
    namespace = local.namespace.metadata[0].name
  }
}
