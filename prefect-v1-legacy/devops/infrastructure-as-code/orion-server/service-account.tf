resource "kubernetes_role" "flow_runner" {
  metadata {
    name      = "flow-runner"
    namespace = "default"
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/status"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }
}

resource "kubernetes_role_binding" "flow_runner_role_binding" {
  metadata {
    name      = "flow-runner-role-binding"
    namespace = "default"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "flow-runner"
  }
}
