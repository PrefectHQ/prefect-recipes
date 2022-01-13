# Prefect deployment terraform module

---

## Description

A terraform module to deploy the prefect agent on Amazon EKS cluster.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.4.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.prefect_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.prefect_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_secretsmanager_secret_version.prefect_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api"></a> [api](#input\_api) | n/a | `string` | `"api.prefect.io"` | no |
| <a name="input_app"></a> [app](#input\_app) | app | `string` | `"prefect-agent"` | no |
| <a name="input_automount_service_account_token"></a> [automount\_service\_account\_token](#input\_automount\_service\_account\_token) | n/a | `bool` | `true` | no |
| <a name="input_env_secrets"></a> [env\_secrets](#input\_env\_secrets) | a list of maps of env vars to pull from secrets | `list(any)` | `[]` | no |
| <a name="input_env_values"></a> [env\_values](#input\_env\_values) | a mapping of env vars to their values i.e. {ENV\_VAR = 'value'} | `map(any)` | `{}` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | n/a | `string` | `"Always"` | no |
| <a name="input_limit_cpu"></a> [limit\_cpu](#input\_limit\_cpu) | n/a | `string` | `"500m"` | no |
| <a name="input_limit_mem"></a> [limit\_mem](#input\_limit\_mem) | n/a | `string` | `"128Mi"` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | n/a | `string` | `"INFO"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"prefect"` | no |
| <a name="input_node_affinity"></a> [node\_affinity](#input\_node\_affinity) | n/a | <pre>object({<br>    key      = string<br>    operator = string<br>    values   = tuple([string])<br>  })</pre> | `null` | no |
| <a name="input_prefect_api_secret_id"></a> [prefect\_api\_secret\_id](#input\_prefect\_api\_secret\_id) | Secret ID for Prefect Cloud api key stored in AWS secrets manager | `string` | n/a | yes |
| <a name="input_prefect_labels"></a> [prefect\_labels](#input\_prefect\_labels) | n/a | `string` | `"[]"` | no |
| <a name="input_prefect_version"></a> [prefect\_version](#input\_prefect\_version) | n/a | `string` | `"latest"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | n/a | `number` | `1` | no |
| <a name="input_request_cpu"></a> [request\_cpu](#input\_request\_cpu) | n/a | `string` | `"100m"` | no |
| <a name="input_request_mem"></a> [request\_mem](#input\_request\_mem) | resources | `string` | `"100Mi"` | no |
| <a name="input_secret_volumes"></a> [secret\_volumes](#input\_secret\_volumes) | n/a | `list(any)` | `[]` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | n/a | `string` | `"prefect-agent"` | no |
| <a name="input_start_args"></a> [start\_args](#input\_start\_args) | n/a | `string` | `""` | no |
| <a name="input_volume_mounts"></a> [volume\_mounts](#input\_volume\_mounts) | n/a | `map(any)` | `{}` | no |

## Outputs

No outputs.

## Usage
```
module "prefect_agent" {
  source      = "path/to/prefect-agent"

  prefect_api_secret_id = "xxxxxxxxxxxxxxxxx"
}
```