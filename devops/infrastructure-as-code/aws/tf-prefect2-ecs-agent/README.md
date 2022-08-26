# Prefect 2 Agent on ECS Fargate

This recipe demonstrates how to deploy a Prefect 2 agent onto ECS Fargate. It can be used as a Terrafrom module as described below.

## Usage

```hcl
module "prefect-ecs-agent" {
  source = "github.com/PrefectHQ/prefect-recipes//devops/infrastructure-as-code/aws/tf-prefect2-ecs-agent"

  agent_subnets        = []
  prefect_account_id   = ""
  prefect_api_key      = ""
  prefect_workspace_id = ""
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_cpu"></a> [agent\_cpu](#input\_agent\_cpu) | CPU units to allocate to agent | `number` | `1024` | no |
| <a name="input_agent_desired_count"></a> [agent\_desired\_count](#input\_agent\_desired\_count) | Number of agents to run | `number` | `1` | no |
| <a name="input_agent_image"></a> [agent\_image](#input\_agent\_image) | Container image for the agent | `string` | `"prefecthq/prefect:2.2.0-python3.10"` | no |
| <a name="input_agent_memory"></a> [agent\_memory](#input\_agent\_memory) | Memory units to allocate to agent | `number` | `2048` | no |
| <a name="input_agent_queue_name"></a> [agent\_queue\_name](#input\_agent\_queue\_name) | Queue that agent should listen to | `string` | `"default"` | no |
| <a name="input_agent_subnets"></a> [agent\_subnets](#input\_agent\_subnets) | Subnets to place fargate tasks in | `list(string)` | n/a | yes |
| <a name="input_agent_task_role_arn"></a> [agent\_task\_role\_arn](#input\_agent\_task\_role\_arn) | Optional task role to pass to the agent | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to place resources in | `string` | `"us-east-1"` | no |
| <a name="input_prefect_account_id"></a> [prefect\_account\_id](#input\_prefect\_account\_id) | Prefect cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | Prefect cloud API key | `string` | n/a | yes |
| <a name="input_prefect_workspace_id"></a> [prefect\_workspace\_id](#input\_prefect\_workspace\_id) | Prefect cloud workspace ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_prefect_agent_service_id"></a> [prefect\_agent\_service\_id](#output\_prefect\_agent\_service\_id) | n/a |
