resource "helm_release" "prefect_agent" {
  name       = "prefect-agent"
  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-agent"
  version    = var.prefect_agent_chart_version

  create_namespace = false
  namespace        = kubernetes_namespace_v1.prefect.metadata[0].name

  set {
    name  = "agent.replicaCount"
    value = var.prefect_agent_replicas
    type  = "auto"
  }

  dynamic "set" {
    for_each = length(var.prefect_agent_image_repository) > 0 ? [""] : []

    content {
      name  = "agent.image.repository"
      value = var.prefect_agent_image_repository
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = length(var.prefect_agent_image_tag) > 0 ? [""] : []

    content {
      name  = "agent.image.prefectTag"
      value = var.prefect_agent_image_tag
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = var.prefect_agent_work_queues

    content {
      name  = "agent.config.workQueues[${set.key}]"
      value = set.value
      type  = "string"
    }
  }

  dynamic "set" {
    for_each = length(var.prefect_cloud_api_url) > 0 ? [""] : []

    content {
      name  = "agent.cloudApiConfig.cloudUrl"
      value = var.prefect_cloud_api_url
      type  = "string"
    }
  }

  set {
    name  = "agent.cloudApiConfig.accountId"
    value = var.prefect_cloud_account_id
    type  = "string"
  }

  set {
    name  = "agent.cloudApiConfig.workspaceId"
    value = var.prefect_cloud_workspace_id
    type  = "string"
  }
}
