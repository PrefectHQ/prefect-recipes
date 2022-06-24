# AKS Terraform Module

---

## Description

A terraform module to deploy an Azure AKS cluster with the Prefect agent installed.
Deploys a storage account and container for Prefect logs.

## Usage

```hcl
module "aks_cluster" {
  source      = "path/to/aks"
  env_name     = "dev/stage/prod"
  cluster_name = "akscluster"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurecli"></a> [azurecli](#requirement\_aws) | >= 2.37.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.11.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [aws](#provider\_azurerm) | 3.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.20.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | a name for the cluster | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | environment of eks deployment | `string` | n/a | yes |
| <a name="input_k8s_cluster_version"></a> [k8s\_cluster\_version](#input\_k8s\_cluster\_version) | version number to use for the cluster | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | private subnets in which cluster nodes will be created | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID for the VPC in which the cluster will be created | `string` | n/a | yes |
| <a name="input_config_id"></a> [config\_id](#input\_config\_id) | config id to provide to the agent to connect with prefect automations | `string` | `""` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | additional IAM Roles to add to the aws-auth configmap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | additional IAM users to add to the aws-auth configmap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_prefect_api_secret_id"></a> [prefect\_api\_secret\_id](#input\_prefect\_api\_secret\_id) | AWS secrets manager secret ID for the API key to allow the prefect agent to communicate with Prefect cloud | `string` | `"prefect-api-key"` | no |
| <a name="input_prefect_secret_key"></a> [prefect\_secret\_key](#input\_prefect\_secret\_key) | key of aws secrets manager secret for prefect api key | `string` | `"key"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->