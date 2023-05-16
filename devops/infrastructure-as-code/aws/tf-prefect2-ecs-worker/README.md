# Prefect 2 worker on ECS Fargate

This recipe demonstrates how to deploy a Prefect 2 worker onto ECS Fargate using [Terraform](https://www.terraform.io/). It is intended to be used as a Terraform module as described in [Usage](#usage) below. It assumes you have Terraform installed, and was tested with Terraform `v1.4.6`.

Note that flows will run inside the worker ECS task, as opposed to becoming their own ECS tasks.

## Usage

![image](https://user-images.githubusercontent.com/68969861/215828678-99f395b4-6ae0-4c8a-8c59-af8e85c7dce4.png)

To start with you will need your Prefect account ID, workspace ID, and API key. You will also need to pick one or more subnets that Fargate will launch into, as well as give your deployment a name.

In order to avoid accidentally committing your API key, consider structuring your project as follows,

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

```hcl
// main.tf

provider "aws" {
  region = "us-east-1"
}

// Don't panic! These values are just random uuid.uuid4()s
module "prefect_ecs_worker" {
  source = "github.com/PrefectHQ/prefect-recipes/devops/infrastructure-as-code/aws/tf-prefect2-ecs-worker"

  worker_subnets        = [
    "subnet-014aa5f348034e45b",
    "subnet-df23ae9eab1f49af9"
  ]
  name                  = "dev"
  prefect_account_id    = "6e02a1db-07de-4760-a15d-60d8fe0b04e1"
  prefect_api_key       = var.prefect_api_key
  prefect_workspace_id  = "54cdfc71-9f13-41ba-9492-e1cf24eed185"
  worker_work_pool_name = "my-ecs-pool"
  vpc_id                = "vpc-acfc2092275244ca8"
}
```

Assuming the file structure above, you can run `terraform init` followed by `terraform apply` to create the resources. Check out the [Inputs](#inputs) section below for more options.

## Reference

The [terraform docs](https://terraform-docs.io/) below can be generated with the following command:

```sh
terraform-docs markdown table . --output-file README.md
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.prefect_worker_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.prefect_worker_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.prefect_worker_cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.prefect_worker_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.prefect_worker_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.prefect_worker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.prefect_worker_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_secretsmanager_secret.prefect_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.prefect_api_key_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.prefect_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.https_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Unique name for this worker deployment | `string` | n/a | yes |
| <a name="input_prefect_account_id"></a> [prefect\_account\_id](#input\_prefect\_account\_id) | Prefect cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | Prefect cloud API key | `string` | n/a | yes |
| <a name="input_prefect_workspace_id"></a> [prefect\_workspace\_id](#input\_prefect\_workspace\_id) | Prefect cloud workspace ID | `string` | n/a | yes |
| <a name="input_secrets_manager_recovery_in_days"></a> [secrets\_manager\_recovery\_in\_days](#input\_secrets\_manager\_recovery\_in\_days) | Deletion delay for AWS Secrets Manager upon resource destruction | `number` | `30` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID in which to create all resources | `string` | n/a | yes |
| <a name="input_worker_cpu"></a> [worker\_cpu](#input\_worker\_cpu) | CPU units to allocate to the worker | `number` | `1024` | no |
| <a name="input_worker_desired_count"></a> [worker\_desired\_count](#input\_worker\_desired\_count) | Number of workers to run | `number` | `1` | no |
| <a name="input_worker_extra_pip_packages"></a> [worker\_extra\_pip\_packages](#input\_worker\_extra\_pip\_packages) | Packages to install on the worker assuming image is based on prefecthq/prefect | `string` | `"prefect-aws s3fs"` | no |
| <a name="input_worker_image"></a> [worker\_image](#input\_worker\_image) | Container image for the worker. This could be the name of an image in a public repo or an ECR ARN | `string` | `"prefecthq/prefect:2-python3.10"` | no |
| <a name="input_worker_log_retention_in_days"></a> [worker\_log\_retention\_in\_days](#input\_worker\_log\_retention\_in\_days) | Number of days to retain worker logs for | `number` | `30` | no |
| <a name="input_worker_memory"></a> [worker\_memory](#input\_worker\_memory) | Memory units to allocate to the worker | `number` | `2048` | no |
| <a name="input_worker_subnets"></a> [worker\_subnets](#input\_worker\_subnets) | Subnets to place the worker in | `list(string)` | n/a | yes |
| <a name="input_worker_task_role_arn"></a> [worker\_task\_role\_arn](#input\_worker\_task\_role\_arn) | Optional task role ARN to pass to the worker. If not defined, a task role will be created | `string` | `null` | no |
| <a name="input_worker_work_pool_name"></a> [worker\_work\_pool\_name](#input\_worker\_work\_pool\_name) | Work pool that the worker should listen to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_prefect_worker_cluster_name"></a> [prefect\_worker\_cluster\_name](#output\_prefect\_worker\_cluster\_name) | n/a |
| <a name="output_prefect_worker_execution_role_arn"></a> [prefect\_worker\_execution\_role\_arn](#output\_prefect\_worker\_execution\_role\_arn) | n/a |
| <a name="output_prefect_worker_security_group"></a> [prefect\_worker\_security\_group](#output\_prefect\_worker\_security\_group) | n/a |
| <a name="output_prefect_worker_service_id"></a> [prefect\_worker\_service\_id](#output\_prefect\_worker\_service\_id) | n/a |
| <a name="output_prefect_worker_task_role_arn"></a> [prefect\_worker\_task\_role\_arn](#output\_prefect\_worker\_task\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
