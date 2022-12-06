# Prefect Agent on a GCP Managed Instance Group

## Purpose
This recipe will walk you through the process to deploy a Prefect Agent using a GCP Managed Instance Group

## Prerequisites
1. Privileges to create service accounts & instances in GCP
2. Terraform (CLI Locally)[https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli]

## Steps
1. Create a VPC and Subnet that have external internet access
2. Create a Work Queue in Prefect Cloud that the agent will be associated with
3. Run `terraform apply` from your local machine
    1. Pass in requested variables
4. Wait for the Work Queue to become `Healthy` in the Prefect Cloud UI
5. You should now be able to run Deployments against your new Prefect Agent
    1. Note that the VM has only Docker and Prefect installed by default.  Other possible python modules may need to be added by updating the (`prefect-agent.sh.tpl`)[https://github.com/PrefectHQ/prefect-recipes/blob/main/devops/infrastructure-as-code/gcp/prefect2-mig/prefect-agent.sh.tpl] file to include the installation of other python modules.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.44.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.44.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance_group"></a> [instance\_group](#module\_instance\_group) | terraform-google-modules/vm/google//modules/mig | 7.9.0 |
| <a name="module_instance_template"></a> [instance\_template](#module\_instance\_template) | terraform-google-modules/vm/google//modules/instance_template | 7.9.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_binding.prefect_agent_gcs](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.prefect_agent_instance_group](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.prefect_agent_gcs](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/project_iam_custom_role) | resource |
| [google_service_account.prefect_agent](https://registry.terraform.io/providers/hashicorp/google/4.44.1/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | environment stage to apply to the agent | `string` | n/a | yes |
| <a name="input_prefect_account_id"></a> [prefect\_account\_id](#input\_prefect\_account\_id) | prefect cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | prefect cloud api key | `string` | n/a | yes |
| <a name="input_prefect_workspace_id"></a> [prefect\_workspace\_id](#input\_prefect\_workspace\_id) | prefect cloud workspace ID | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | google cloud project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the resources to | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | subnet to deploy the managed instance group | `string` | n/a | yes |
| <a name="input_work_queue"></a> [work\_queue](#input\_work\_queue) | prefect cloud work queue name | `string` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the Prefect Agent VM disk | `string` | `"20"` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type to be used by the Prefect Agent VM | `string` | `"pd-standard"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCP Machine type to be used for the Prefect Agent VM | `string` | `"n2d-highcpu-2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the instance name | `string` | `"prefect-agent"` | no |
| <a name="input_num_vm"></a> [num\_vm](#input\_num\_vm) | Number of deployed VMs in the managed instance group | `number` | `1` | no |
| <a name="input_preemptible"></a> [preemptible](#input\_preemptible) | prefect cloud account ID | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->