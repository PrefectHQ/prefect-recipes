# TFC-Agent Module
Creates Service Accounts and TFE Agent GCP VM to deploy the agent to our GCP `networking` Projects.
The GCP VM is a Container Optimized Instance that runs the TFE Agent as a Docker container.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.44.1 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | 0.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.44.1 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | 0.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance_group"></a> [instance\_group](#module\_instance\_group) | terraform-google-modules/vm/google//modules/mig | 7.8.0 |
| <a name="module_instance_template"></a> [instance\_template](#module\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | 7.8.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_binding.tfc_agent_vm](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/project_iam_binding) | resource |
| [google_service_account.tfc_agent](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/service_account) | resource |
| [tfe_agent_pool.agent_pool](https://registry.terraform.io/providers/hashicorp/tfe/0.35.0/docs/resources/agent_pool) | resource |
| [tfe_agent_token.agent_token](https://registry.terraform.io/providers/hashicorp/tfe/0.35.0/docs/resources/agent_token) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | environment stage to apply to the agent | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | google cloud project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the resources to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | The ID of the Terraform Cloud agent pool created within the network |
<!-- END_TF_DOCS -->
