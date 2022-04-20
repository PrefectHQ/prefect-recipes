resource "kubernetes_service_account" "agent" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.namespace.id
  }
}

resource "kubernetes_role" "prefect_agent" {
  metadata {
    name      = "prefect-agent"
    namespace = kubernetes_namespace.namespace.id
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
}

resource "kubernetes_role_binding" "prefect_agent" {
  metadata {
    name      = "prefect-agent"
    namespace = kubernetes_namespace.namespace.id
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.prefect_agent.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.agent.metadata[0].name
    namespace = kubernetes_namespace.namespace.id
  }
}