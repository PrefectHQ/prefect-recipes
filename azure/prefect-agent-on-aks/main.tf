module "dev_cluster" {
  source       = "./aks_main"
  env_name     = "dev"
  cluster_name = "prefectAKS"
}

# module "prod_cluster" {
#     source       = "./aks_main"
#     env_name     = "prod"
#     cluster_name = "prefectAKS"
# }