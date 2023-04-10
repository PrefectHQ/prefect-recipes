# EKS

This recipe demonstrates how to deploy a Prefect 2 agent or Kubernetes worker into an AWS EKS cluster using [Terraform](https://www.terraform.io/). While you may use this as a Terraform module, we recommend treating it as an example and copying the module contents into your repository. Once the agent deployed, you will be able to run flows using [`KubernetesJob`](https://docs.prefect.io/concepts/infrastructure/#kubernetesjob) infrastructure blocks.

## Prerequisites

* Credentials for Prefect Cloud (your Prefect Account ID, Workspace ID, and API Key)
* An Amazon Web Services account with a VPC and one or more subnets for the cluster, and a deployment role with sufficient permissions to create an EKS cluster
* A recent version of Terraform (we tested with Terraform 1.4.2)
* Suitable permissions to create an EKS cluster and configure associated IAM policies (we recommend using an isolated account for this purpose)

## Limitations

The recipe is intended for simple use cases, so has some limitations:

* Prefect does not provide backward compatibility guarantees for this recipe, and new versions may have breaking changes
* Some customizations are not supported by the module, by design
* The module requires a public cluster endpoint to simplify deployment of the Helm chart for the agent or worker
* IAM Roles for Service Accounts is required; we use this to provide credentials to the agent and worker Kubernetes service account
* The module supports EKS Managed Node Groups; for other node types, you will need to modify the module source code

## Usage

In order to avoid accidentally committing your API key, consider structuring your project as follows:

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

For a usage example, see [`main.tf](./example/main.tf):

```hcl
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
```

Assuming the file structure above, you can run `terraform init` followed by `terraform apply` to create the resources. Review the [Inputs section](#inputs) for other settings.

<!-- BEGIN_TF_DOCS -->
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
| <a name="module_cluster"></a> [cluster](#module\_cluster) | terraform-aws-modules/eks/aws | 19.12.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.prefect_agent](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [kubernetes_namespace_v1.prefect](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.prefect_api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_aws_auth_accounts"></a> [cluster\_aws\_auth\_accounts](#input\_cluster\_aws\_auth\_accounts) | Setting for aws\_auth\_accounts (by default, will be the account\_id) | `list(string)` | `null` | no |
| <a name="input_cluster_create_aws_auth_configmap"></a> [cluster\_create\_aws\_auth\_configmap](#input\_cluster\_create\_aws\_auth\_configmap) | Create the aws\_auth ConfigMap (see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1266937679) | `bool` | `false` | no |
| <a name="input_cluster_eks_managed_node_groups"></a> [cluster\_eks\_managed\_node\_groups](#input\_cluster\_eks\_managed\_node\_groups) | Cluster EKS managed node groups | `any` | <pre>{<br>  "capacity_type": "SPOT",<br>  "desired_size": 1,<br>  "instance_types": [<br>    "m6a.large"<br>  ],<br>  "max_size": 10,<br>  "min_size": 1<br>}</pre> | no |
| <a name="input_cluster_manage_aws_auth_configmap"></a> [cluster\_manage\_aws\_auth\_configmap](#input\_cluster\_manage\_aws\_auth\_configmap) | Manage the aws\_auth ConfigMap (see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1720#issuecomment-1266937679) | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `"prefect"` | no |
| <a name="input_cluster_subnet_ids"></a> [cluster\_subnet\_ids](#input\_cluster\_subnet\_ids) | Subnet IDs to place cluster in | `list(string)` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to associate with cluster resources (a default cluster\_name tag will apply) | `map(any)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the cluster | `string` | `"1.24"` | no |
| <a name="input_cluster_vpc_id"></a> [cluster\_vpc\_id](#input\_cluster\_vpc\_id) | ID of VPC to place cluster in | `string` | n/a | yes |
| <a name="input_prefect_agent_chart_version"></a> [prefect\_agent\_chart\_version](#input\_prefect\_agent\_chart\_version) | Prefect agent Helm chart version to install (defaults to the latest version) | `string` | `""` | no |
| <a name="input_prefect_agent_image_repository"></a> [prefect\_agent\_image\_repository](#input\_prefect\_agent\_image\_repository) | Image repository to use for the agent (defaults to the value included in the Helm chart) | `string` | `""` | no |
| <a name="input_prefect_agent_image_tag"></a> [prefect\_agent\_image\_tag](#input\_prefect\_agent\_image\_tag) | Tag of image to use for the agent (defaults to the value included in the Helm chart) | `string` | `""` | no |
| <a name="input_prefect_agent_replicas"></a> [prefect\_agent\_replicas](#input\_prefect\_agent\_replicas) | Number of Prefect agent replicas to run in the cluster | `number` | `1` | no |
| <a name="input_prefect_agent_work_queue"></a> [prefect\_agent\_work\_queue](#input\_prefect\_agent\_work\_queue) | Name of Prefect work queue that agents will subscribe to | `string` | `"default"` | no |
| <a name="input_prefect_cloud_account_id"></a> [prefect\_cloud\_account\_id](#input\_prefect\_cloud\_account\_id) | Prefect Cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_cloud_api_key"></a> [prefect\_cloud\_api\_key](#input\_prefect\_cloud\_api\_key) | Prefect Cloud API key | `string` | n/a | yes |
| <a name="input_prefect_cloud_workspace_id"></a> [prefect\_cloud\_workspace\_id](#input\_prefect\_cloud\_workspace\_id) | Prefect Cloud workspace ID | `string` | n/a | yes |
| <a name="input_prefect_namespace"></a> [prefect\_namespace](#input\_prefect\_namespace) | Kubernetes namespace to create | `string` | `"prefect"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
