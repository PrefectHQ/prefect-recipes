# Prefect Agent Helm Terraform module

---

## Description

A terraform module to deploy the prefect agent to any kubernetes cluster using the official helm chart. 

## Usage

Use the `set` blocks to pass configuration data to the helm chart or provide a `values.yaml` file.

```hcl
module "prefect_agent" {
  source      = "path/to/prefect-agent"

  prefect_cloud_account_id   = "xxxxxxxxxxxxxxxxx"
  prefect_cloud_workspace_id = "xxxxxxxxxxxxxxxxx"
  api_key                    = "pnu_xxxxxxxxxxxxxxxxx"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.7.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.agent](https://registry.terraform.io/providers/hashicorp/helm/2.7.1/docs/resources/release) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/2.14.0/docs/resources/namespace) | resource |
| [kubernetes_secret.api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/2.14.0/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefect_cloud_account_id"></a> [prefect\_cloud\_account\_id](#input\_prefect\_cloud\_account\_id) | prefect cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_cloud_workspace_id"></a> [prefect\_cloud\_workspace\_id](#input\_prefect\_cloud\_workspace\_id) | prefect cloud workspace ID | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | provide prefect cloud API key here to create a secret within k8s, otherwise provide the name of an existing secret | `string` | `null` | no |
| <a name="input_api_key_secret"></a> [api\_key\_secret](#input\_api\_key\_secret) | name & key of k8s secret that contains the prefect cloud API key | <pre>object({<br>    secret_name = string<br>    secret_key  = string<br>  })</pre> | <pre>{<br>  "secret_key": "key",<br>  "secret_name": "prefect-api-key"<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | optionally create the namespace to deploy the chart & agent to | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | namespace to deploy the agent into | `string` | `"prefect"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
