# Prefect Agent on ECS

---

## Description

Deploy the Prefect agent on AWS Elastic Container Service as a long running service

## Usage:

```
module "prefect_agent" {
  source      = "path/to/prefect-agent-on-ecs"

  prefect_api_key = "xxxxxxxxxxxxxxxxx"
  vpc_id          = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_ids      = ["subnet-xxxxxxxxxxxxxxxxx","subnet-xxxxxxxxxxxxxxxxx"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.prefect_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_execution_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.prefect_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.ecs_execution_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_policy_attachment.prefect_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.prefect_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.prefect_ecs_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.bucket_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.network_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.prefect_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_execution_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.prefect_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | Prefect service account API key | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | subnet IDs to deploy the Prefect ECS agent into | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to deploy the Prefect ECS agent into | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of ECS Cluster in which to create all resources | `string` | `"prefect"` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | custom tags which can be passed on to the AWS resources. they should be key value pairs having distinct keys. | `map(any)` | `{}` | no |
| <a name="input_default_task_cpu"></a> [default\_task\_cpu](#input\_default\_task\_cpu) | Default memory for ecs flow tasks | `number` | `1024` | no |
| <a name="input_default_task_memory"></a> [default\_task\_memory](#input\_default\_task\_memory) | Default memory for ecs flow tasks | `number` | `2048` | no |
| <a name="input_flow_log_group_name"></a> [flow\_log\_group\_name](#input\_flow\_log\_group\_name) | Name of Cloudwatch Log group for Prefect Flows | `string` | `"prefect-flows"` | no |
| <a name="input_flow_log_stream_prefix"></a> [flow\_log\_stream\_prefix](#input\_flow\_log\_stream\_prefix) | Prefix for all flow log streams | `string` | `"ecs-prefect"` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | logging level to apply to the ECS Prefect agent | `string` | `"INFO"` | no |
| <a name="input_prefect_api_address"></a> [prefect\_api\_address](#input\_prefect\_api\_address) | the api address that the prefect agent queries for pending flow runs | `string` | `"https://api.prefect.io"` | no |
| <a name="input_prefect_labels"></a> [prefect\_labels](#input\_prefect\_labels) | labels to apply to the prefect agent | `string` | `""` | no |
| <a name="input_prefect_version"></a> [prefect\_version](#input\_prefect\_version) | Prefect core version for the agent to run | `string` | `"1.2.0"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region in which to create resources | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->