# EKS terraform module

---

## Description

A terraform module to deploy an Amazon EKS cluster with the Prefect agent installed.

## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 0.13  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >= 3.4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                   | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl)          | 1.11.3   |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.3.1 |

## Providers

| Name                                                                | Version  |
| ------------------------------------------------------------------- | -------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                   | >= 3.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a      |

## Modules

| Name                                                                                         | Source                        | Version |
| -------------------------------------------------------------------------------------------- | ----------------------------- | ------- |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./autoscaler                  | n/a     |
| <a name="module_eks"></a> [eks](#module\_eks)                                                | terraform-aws-modules/eks/aws | 17.20.0 |
| <a name="module_prefect_agent"></a> [prefect\_agent](#module\_prefect\_agent)                | ./prefect-agent               | n/a     |

## Resources

| Name                                                                                                                                                | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                             | resource    |
| [aws_iam_role_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)                               | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth)                     | data source |
| [aws_iam_policy_document.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)        | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state)                     | data source |

## Inputs

| Name                                                                                                    | Description                                                          | Type                                                                                                               | Default             | Required |
| ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)                                | a name for the cluster                                               | `string`                                                                                                           | n/a                 |   yes    |
| <a name="input_environment"></a> [environment](#input\_environment)                                     | environment of eks deployment                                        | `string`                                                                                                           | n/a                 |   yes    |
| <a name="input_k8s_cluster_version"></a> [k8s\_cluster\_version](#input\_k8s\_cluster\_version)         | version number to use for the cluster                                | `string`                                                                                                           | n/a                 |   yes    |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles)                                         | Additional IAM Roles to add to the aws-auth configmap                | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]`                |    no    |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users)                                         | additional IAM users to add to the aws-auth configmap                | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]`                |    no    |
| <a name="input_prefect_api_secret_id"></a> [prefect\_api\_secret\_id](#input\_prefect\_api\_secret\_id) | API key to allow the prefect agent to communicate with Prefect cloud | `string`                                                                                                           | `"prefect_api_key"` |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                    | region to deploy resources into                                      | `string`                                                                                                           | n/a                 |   yes    |

## Outputs

No outputs.

## Usage
```
module "eks" {
  source      = "path/to/eks"

  cluster_name        = "xxxxxxxxxxxxxxxxx"
  region              = "xxxxxxxxxxxxxxxxx"
  environment         = "xxxxxxxxxxxxxxxxx"
  k8s_cluster_version = "xxxxxxxxxxxxxxxxx"
  vpc_id              = "xxxxxxxxxxxxxxxxx"
  private_subnet_ids  = "xxxxxxxxxxxxxxxxx"
}
```