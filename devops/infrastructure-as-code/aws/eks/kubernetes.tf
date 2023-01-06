// Prefect agent Helm chart expects this secret
resource "kubernetes_secret" "prefect_api_key" {
  metadata {
    name = "prefect-api-key"
  }

  data = {
    key = var.prefect_cloud_api_key
  }
}

// Use Helm to install the Prefect agent
resource "helm_release" "prefect_agent" {
  name       = "prefect-agent"
  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-agent"

  set {
    name  = "agent.config.workQueues[0]"
    value = var.prefect_agent_work_queue
  }

  set {
    name  = "agent.cloudApiConfig.accountId"
    value = var.prefect_cloud_account_id
  }

  set {
    name  = "agent.cloudApiConfig.workspaceId"
    value = var.prefect_cloud_workspace_id
  }

  set {
    name  = "agent.image.repository"
    value = var.prefect_agent_image_repository
  }

  set {
    name  = "agent.image.prefectTag"
    value = var.prefect_agent_image_tag
  }

  set {
    name  = "agent.replicaCount"
    value = var.prefect_agent_count
  }
}
