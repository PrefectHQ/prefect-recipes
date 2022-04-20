# Prefect deployment terraform module

---

## Description

A terraform module to deploy the Prefect Orion Server on Kubernetes.

## Usage

```hcl
module "prefect_agent" {
  source      = "path/to/prefect-agent"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.4.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.orion](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_role.flow_runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.flow_runner_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service.orion](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name for kubernetes services | `string` | `"orion"` | no |
| <a name="input_automount_service_account_token"></a> [automount\_service\_account\_token](#input\_automount\_service\_account\_token) | n/a | `bool` | `true` | no |
| <a name="input_env_secrets"></a> [env\_secrets](#input\_env\_secrets) | a list of maps of env vars to pull from secrets | `list(any)` | `[]` | no |
| <a name="input_env_values"></a> [env\_values](#input\_env\_values) | a mapping of env vars to their values i.e. {ENV\_VAR = 'value'} | `map(any)` | `{}` | no |
| <a name="input_image_pull_policy"></a> [image\_pull\_policy](#input\_image\_pull\_policy) | Image pull policy for kubernetes services | `string` | `"Always"` | no |
| <a name="input_kubernetes_resources_labels"></a> [kubernetes\_resources\_labels](#input\_kubernetes\_resources\_labels) | Labels to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | Setting for logging level | `string` | `"INFO"` | no |
| <a name="input_metadata-labels"></a> [metadata-labels](#input\_metadata-labels) | Metadata labels to apply to kubernetes services | `list(any)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Select kubernetes namespace in which to deploy | `string` | `"prefect"` | no |
| <a name="input_node_affinity"></a> [node\_affinity](#input\_node\_affinity) | Maps of node affinity settings for kubernetes resources | <pre>object({<br>    key      = string<br>    operator = string<br>    values   = tuple([string])<br>  })</pre> | `null` | no |
| <a name="input_orion_server_limit_cpu"></a> [orion\_server\_limit\_cpu](#input\_orion\_server\_limit\_cpu) | CPU Limit for orion server | `string` | `"500m"` | no |
| <a name="input_orion_server_limit_mem"></a> [orion\_server\_limit\_mem](#input\_orion\_server\_limit\_mem) | Memory limit for orion server | `string` | `"128Mi"` | no |
| <a name="input_orion_server_request_cpu"></a> [orion\_server\_request\_cpu](#input\_orion\_server\_request\_cpu) | CPU request for orion server | `string` | `"100m"` | no |
| <a name="input_orion_server_request_mem"></a> [orion\_server\_request\_mem](#input\_orion\_server\_request\_mem) | Memory request for orion server | `string` | `"100Mi"` | no |
| <a name="input_port"></a> [port](#input\_port) | Port for the service to expose | `number` | `4200` | no |
| <a name="input_prefect_agent_limit_cpu"></a> [prefect\_agent\_limit\_cpu](#input\_prefect\_agent\_limit\_cpu) | CPU limit for prefect agent | `string` | `"500m"` | no |
| <a name="input_prefect_agent_limit_mem"></a> [prefect\_agent\_limit\_mem](#input\_prefect\_agent\_limit\_mem) | Memory limit for prefect agent | `string` | `"128Mi"` | no |
| <a name="input_prefect_agent_request_cpu"></a> [prefect\_agent\_request\_cpu](#input\_prefect\_agent\_request\_cpu) | CPU request for prefect agent | `string` | `"100m"` | no |
| <a name="input_prefect_agent_request_mem"></a> [prefect\_agent\_request\_mem](#input\_prefect\_agent\_request\_mem) | Memory request for prefect agent | `string` | `"100Mi"` | no |
| <a name="input_prefect_version"></a> [prefect\_version](#input\_prefect\_version) | Prefect image version | `string` | `"2.0b3"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of kubernetes replicas to deploy | `number` | `1` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Kubernetes service account name | `string` | `"prefect-orion"` | no |
| <a name="input_start_args"></a> [start\_args](#input\_start\_args) | Arguments to pass to the `prefect orion agent start` command | `string` | `""` | no |
| <a name="input_volume_mounts"></a> [volume\_mounts](#input\_volume\_mounts) | Volume mounts for kubernetes pods | `map(any)` | `{}` | no |
| <a name="input_work_queue_id"></a> [work\_queue\_id](#input\_work\_queue\_id) | Prefect work queue to subscribe agent to | `string` | `"kubernetes"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->