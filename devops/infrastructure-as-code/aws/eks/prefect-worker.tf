resource "helm_release" "prefect_worker" {
  name       = "prefect-worker"
  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-worker"
  version    = var.prefect_worker_chart_version

  create_namespace = false
  namespace        = kubernetes_namespace_v1.prefect.metadata[0].name

  set {
    name  = "worker.replicaCount"
    value = var.prefect_worker_replicas
    type  = "auto"
  }

  dynamic "set" {
    for_each = length(var.prefect_worker_image_repository) > 0 ? [""] : []

    content {
      name  = "worker.image.repository"
      value = var.prefect_worker_image_repository
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = length(var.prefect_worker_image_tag) > 0 ? [""] : []

    content {
      name  = "worker.image.prefectTag"
      value = var.prefect_worker_image_tag
      type  = "string"
    }
  }

  set {
    name  = "worker.config.workPool"
    value = var.prefect_worker_work_pool
    type  = "string"
  }

  dynamic "set" {
    for_each = length(var.prefect_cloud_api_url) > 0 ? [""] : []

    content {
      name  = "worker.cloudApiConfig.cloudUrl"
      value = var.prefect_cloud_api_url
      type  = "string"
    }
  }

  set {
    name  = "worker.cloudApiConfig.accountId"
    value = var.prefect_cloud_account_id
    type  = "string"
  }

  set {
    name  = "worker.cloudApiConfig.workspaceId"
    value = var.prefect_cloud_workspace_id
    type  = "string"
  }
}
