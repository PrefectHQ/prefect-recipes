# EKS

This recipe demonstrates how to deploy a Prefect 2 agent onto an AWS EKS cluster using [Terraform](https://www.terraform.io/). It is intended to be used as a Terraform module as described in [Usage](#usage) below. It assumes you have Terraform installed, and was tested with Terraform `v1.2.7`.

Once the agent deployed, you will be able to run flows using [`KubernetesJob`](https://docs.prefect.io/concepts/infrastructure/#kubernetesjob) infrastructure blocks.

## Usage

To start with you will need your Prefect account ID, workspace ID, and API key. You will also need to pick a VPC and one or more subnets that cluster nodes will launch into, as well as give your cluster a name.

In order to avoid accidentally committing your API key, consider structuring your project as follows,

```
.
├── main.tf
├── terraform.tfvars
└── variables.tf
```

```hcl
// variables.tf
variable prefect_api_key {}
```

```hcl
// terraform.tfvars
// Don't panic! This isn't a real API key
prefect_api_key = "pnu_bcf655365883614d468990896264f6a30372"
```

```hcl
// Don't panic! These values are just random uuid.uuid4()s
module "eks" {
  source = "github.com/PrefectHQ/prefect-recipes//devops/infrastructure-as-code/aws/eks"

  cluster_name   = "prefect-dev"
  cluster_vpc_id = "vpc-39457b263e5a45e69"
  cluster_subnet_ids = [
    "subnet-014aa5f348034e45b",
    "subnet-df23ae9eab1f49af9"
  ]

  prefect_cloud_account_id   = "6e02a1db-07de-4760-a15d-60d8fe0b04e1"
  prefect_cloud_api_key      = var.prefect_cloud_api_key
  prefect_cloud_workspace_id = "54cdfc71-9f13-41ba-9492-e1cf24eed185"
}
```

Assuming the file structure above, you can run `terraform init` followed by `terraform apply` to create the resources. Check out the [Inputs](#inputs) section below for more options.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.45.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.7.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.16.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.16.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 18.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.prefect_agent](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [kubernetes_secret.prefect_api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_node_capacity_type"></a> [cluster\_node\_capacity\_type](#input\_cluster\_node\_capacity\_type) | Capacity type for nodes in cluster | `string` | `"SPOT"` | no |
| <a name="input_cluster_node_instance_type"></a> [cluster\_node\_instance\_type](#input\_cluster\_node\_instance\_type) | Instance type for nodes in cluster | `string` | `"m5.large"` | no |
| <a name="input_cluster_node_max_size"></a> [cluster\_node\_max\_size](#input\_cluster\_node\_max\_size) | Maximum number of nodes in cluster | `number` | `10` | no |
| <a name="input_cluster_node_min_size"></a> [cluster\_node\_min\_size](#input\_cluster\_node\_min\_size) | Minimum number of nodes in cluster | `number` | `1` | no |
| <a name="input_cluster_subnet_ids"></a> [cluster\_subnet\_ids](#input\_cluster\_subnet\_ids) | Subnet IDs to place cluster in | `list(string)` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to associate with cluster resources | `map(any)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the cluster | `string` | `"1.24"` | no |
| <a name="input_cluster_vpc_id"></a> [cluster\_vpc\_id](#input\_cluster\_vpc\_id) | ID of VPC to place cluster in | `string` | n/a | yes |
| <a name="input_prefect_agent_count"></a> [prefect\_agent\_count](#input\_prefect\_agent\_count) | Number of Prefect agents to run in the cluster | `number` | `1` | no |
| <a name="input_prefect_agent_image_repository"></a> [prefect\_agent\_image\_repository](#input\_prefect\_agent\_image\_repository) | Image repository to use for the agent | `string` | `"prefecthq/prefect"` | no |
| <a name="input_prefect_agent_image_tag"></a> [prefect\_agent\_image\_tag](#input\_prefect\_agent\_image\_tag) | Tag of image to use for the agent | `string` | `"2-latest"` | no |
| <a name="input_prefect_agent_work_queue"></a> [prefect\_agent\_work\_queue](#input\_prefect\_agent\_work\_queue) | Name of Prefect work queue that agents will subscribe to | `string` | `"default"` | no |
| <a name="input_prefect_cloud_account_id"></a> [prefect\_cloud\_account\_id](#input\_prefect\_cloud\_account\_id) | Prefect Cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_cloud_api_key"></a> [prefect\_cloud\_api\_key](#input\_prefect\_cloud\_api\_key) | Prefect Cloud API key | `string` | n/a | yes |
| <a name="input_prefect_cloud_workspace_id"></a> [prefect\_cloud\_workspace\_id](#input\_prefect\_cloud\_workspace\_id) | Prefect Cloud workspace ID | `string` | n/a | yes |

## Outputs

No outputs.
