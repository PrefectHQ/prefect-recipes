module "prefect" {
  source = "../"

  account_id   = "1234"
  cluster_name = "prefect-dev"

  cluster_vpc_id = "vpc-39457b263e5a45e69"
  cluster_subnet_ids = [
    "subnet-014aa5f348034e45b",
    "subnet-df23ae9eab1f49af9"
  ]

  prefect_cloud_account_id   = "6e02a1db-07de-4760-a15d-60d8fe0b04e1"
  prefect_cloud_workspace_id = "54cdfc71-9f13-41ba-9492-e1cf24eed185"
  prefect_cloud_api_key      = "pnu_bcf655365883614d468990896264f6a30372"

  prefect_agent_replicas    = 1
  prefect_agent_work_queues = ["test-queue"]

  prefect_worker_replicas  = 1
  prefect_worker_work_pool = "olympic"
}
