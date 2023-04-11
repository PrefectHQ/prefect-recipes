# S3 Eventbridge

This recipe demonstrates how to run a deployment when new files land in S3. Essentially, S3 sends a notification to EventBridge, which in turn calls the Prefect Cloud API. We assume that the flow being run takes a single input named `detail` of type `dict`. The recipe can be extended to use any other EventBridge supported trigger event.

## Example

The following example will run the deployment `d9b5b9e0-1b1a-4b1e-9b1b-1b1a4b1e9b1b` anytime a new file appears in `s3://my-bucket/inbox`:

```hcl
module "s3_eventbridge_to_prefect" {
  source = "github.com/PrefectHQ/prefect-recipes//devops/infrastructure-as-code/aws/s3-eventbridge"

  name                       = "inbox-flow"
  prefect_cloud_account_id   = "6e02a1db-07de-4760-a15d-60d8fe0b04e1"
  prefect_cloud_workspace_id = "54cdfc71-9f13-41ba-9492-e1cf24eed185"
  prefect_cloud_api_key      = var.prefect_api_key

  bucket_name   = "my-bucket"
  object_prefix = "inbox/"
  deployment_id = "d9b5b9e0-1b1a-4b1e-9b1b-1b1a4b1e9b1b"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.61.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_api_destination.prefect_cloud_deployment_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination) | resource |
| [aws_cloudwatch_event_connection.prefect_cloud_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |
| [aws_cloudwatch_event_rule.s3_object_created](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.prefect_cloud_deployment_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.cloudwatch_event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of S3 Bucket for event source | `string` | n/a | yes |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum number of API calls per second | `number` | `10` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for this EventBridge rule and target | `string` | n/a | yes |
| <a name="input_object_prefix"></a> [object\_prefix](#input\_object\_prefix) | Prefix of S3 Object for event source. Leave blank to match all objects. | `string` | `""` | no |
| <a name="input_prefect_cloud_account_id"></a> [prefect\_cloud\_account\_id](#input\_prefect\_cloud\_account\_id) | Prefect Cloud account ID | `string` | n/a | yes |
| <a name="input_prefect_cloud_api_key"></a> [prefect\_cloud\_api\_key](#input\_prefect\_cloud\_api\_key) | Prefect Cloud API key | `string` | n/a | yes |
| <a name="input_prefect_cloud_deployment_id"></a> [prefect\_cloud\_deployment\_id](#input\_prefect\_cloud\_deployment\_id) | Prefect Cloud Deployment ID to trigger | `string` | n/a | yes |
| <a name="input_prefect_cloud_workspace_id"></a> [prefect\_cloud\_workspace\_id](#input\_prefect\_cloud\_workspace\_id) | Prefect Cloud workspace ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->