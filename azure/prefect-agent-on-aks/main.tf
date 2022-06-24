module "dev_cluster" {
    source       = "./aks_main"
    env_name     = "prod"
    cluster_name = "learnk8scluster"
}