module "prefect_agent" {
  source = "./prefect-agent"

  prefect_api_secret_id = var.prefect_api_secret_id
}
