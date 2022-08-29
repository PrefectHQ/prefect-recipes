# Prefect 2 Agent on ECS Fargate

This recipe demonstrates how to deploy a Prefect 2 agent onto ECS Fargate using [Terraform](https://www.terraform.io/). It can be used as a Terraform module as described below.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

// Don't panic! These values are just random uuid.uuid4()'s
module "prefect-ecs-agent" {
  source = "github.com/PrefectHQ/prefect-recipes//devops/infrastructure-as-code/aws/tf-prefect2-ecs-agent"

  agent_subnets        = [
    "subnet-014aa5f348034e45b",
    "subnet-df23ae9eab1f49af9"
  ]
  name                 = "dev"
  prefect_account_id   = "6e02a1db-07de-4760-a15d-60d8fe0b04e1"
  prefect_api_key      = "pnu_bcf655365883614d468990896264f6a30372"
  prefect_workspace_id = "54cdfc71-9f13-41ba-9492-e1cf24eed185"
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.prefect_agent_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.prefect_agent_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.prefect_agent_cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.prefect_agent_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.prefect_agent_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.prefect_agent_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_secretsmanager_secret.prefect_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.prefect_api_key_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_cpu"></a> [agent\_cpu](#input\_agent\_cpu) | CPU units to allocate to the agent | `number` | `1024` | no |
| <a name="input_agent_desired_count"></a> [agent\_desired\_count](#input\_agent\_desired\_count) | Number of agents to run | `number` | `1` | no |
| <a name="input_agent_image"></a> [agent\_image](#input\_agent\_image) | Container image for the agent. This could be the name of an image in a public repo or an ECR ARN | `string` | `"prefecthq/prefect:2-python3.10"` | no |
| <a name="input_agent_log_retention_in_days"></a> [agent\_log\_retention\_in\_days](#input\_agent\_log\_retention\_in\_days) | Number of days to retain agent logs for | `number` | `30` | no |
| <a name="input_agent_memory"></a> [agent\_memory](#input\_agent\_memory) | Memory units to allocate to the agent | `number` | `2048` | no |
| <a name="input_agent_queue_name"></a> [agent\_queue\_name](#input\_agent\_queue\_name) | Prefect queue that the agent should listen to | `string` | `"default"` | no |
| <a name="input_agent_subnets"></a> [agent\_subnets](#input\_agent\_subnets) | Subnets to place the agent in | `list(string)` | n/a | yes |
| <a name="input_agent_task_role_arn"></a> [agent\_task\_role\_arn](#input\_agent\_task\_role\_arn) | Optional task role ARN to pass to the agent | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for this agent deployment | `string` | n/a | yes |
| <a name="input_prefect_account_id"></a> [prefect\_account\_id](#input\_prefect\_account\_id) | Prefect cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | Prefect cloud API key | `string` | n/a | yes |
| <a name="input_prefect_workspace_id"></a> [prefect\_workspace\_id](#input\_prefect\_workspace\_id) | Prefect cloud workspace ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_prefect_agent_service_id"></a> [prefect\_agent\_service\_id](#output\_prefect\_agent\_service\_id) | n/a |
