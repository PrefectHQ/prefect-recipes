module "prefect_agent" {
  source = "./prefect-agent"

  prefect_api_secret_id = var.prefect_api_secret_id
  node_affinity = {
    key      = "base_node"
    operator = "In"
    values   = ["yes"]
  }
}
