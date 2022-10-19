resource "helm_release" "agent" {
  name       = "prefect-agent"
  namespace  = var.namespace
  repository = "https://prefecthq.github.io/prefect-helm/"
  chart      = "prefect-agent"
  version    = "2022.10.18"

  # uncomment if you want to supply your own values file, otherwise - use the set blocks below
  # https://github.com/PrefectHQ/prefect-helm/blob/main/charts/prefect-agent/values.yaml
  # values = [
  #   "${file("values.yaml")}"
  # ]

  set {
    name  = "agent.cloudApiConfig.accountId"
    value = var.prefect_cloud_account_id
  }

  set {
    name  = "agent.cloudApiConfig.workspaceId"
    value = var.prefect_cloud_workspace_id
  }

  set {
    name  = "agent.cloudApiConfig.apiKeySecret.name"
    value = var.api_key_secret.secret_name
  }

  set {
    name  = "agent.cloudApiConfig.apiKeySecret.key"
    value = var.api_key_secret.secret_key
  }
}
