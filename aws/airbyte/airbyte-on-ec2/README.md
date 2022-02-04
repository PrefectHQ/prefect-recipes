# Airbyte on EC2

---

## Description

Deploys Airbyte on an EC2 instance in an autoscaling group

## Usage:

```hcl
module "airbyte" {
  source      = "path/to/airbyte-on-ec2"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  vpc_id        = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_ids    = ["subnet-xxxxxxxxxxxxxxxxx"]
  key_name      = "key.pem"
  ingress_cidrs = ["10.0.0.0/16"]
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.bucket_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.airbyte_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.airbyte_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_iam_policy_document.airbyte](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.airbyte_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI to launch the EC2 instance from | `string` | n/a | yes |
| <a name="input_ingress_cidrs"></a> [ingress\_cidrs](#input\_ingress\_cidrs) | list of cidr ranges to allow ssh access to your airbyte instance | `list(string)` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | ssh key name to use to connect to your airbyte instance | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | IDs of subnets to deploy airbyte instance into | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to deploy the airbyte instance into | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | desired number of Airbyte instances to be running at any given time | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | SDLC stage | `string` | `"dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS instance type, default requirement is t2.large | `string` | `"t2.large"` | no |
| <a name="input_linux_type"></a> [linux\_type](#input\_linux\_type) | type of linux instance | `string` | `"linux_amd64"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | maximum number of Airbyte instances to be running at any given time | `number` | `1` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | minimum number of Airbyte instances to be running at any given time | `number` | `1` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->