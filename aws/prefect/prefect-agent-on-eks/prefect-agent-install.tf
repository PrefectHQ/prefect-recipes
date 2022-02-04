module "prefect_agent" {
  source = "./prefect-agent"

  prefect_api_secret_id = var.prefect_api_secret_id #tfsec:ignore:general-secrets-no-plaintext-exposure
  start_args            = var.config_id != "" ? "--agent-config-id ${var.config_id}" : ""

  node_affinity = {
    key      = "base_node"
    operator = "In"
    values   = ["yes"]
  }
}
