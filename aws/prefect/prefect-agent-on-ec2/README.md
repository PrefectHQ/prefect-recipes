# Prefect Agent on EC2

---

## Description

Deploy 1 or more EC2 instances within an Autoscaling Group that will host the Prefect agent

## Usage:

```
module "prefect_agent" {
  source      = "path/to/prefect-agent-on-ec2"

  ami_id             = "ami-xxxxxxxxxxxxxxxxx"
  environment        = "dev"
  vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
  private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx","subnet-xxxxxxxxxxxxxxxxx"]
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
| [aws_autoscaling_group.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_template.prefect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI to launch the EC2 instance from | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | SDLC stage | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | IDs of the subnets that will host the Prefect agent EC2 instance | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to deploy the Prefect agent into | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | desired number of prefect agents to be running at any given time | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | AWS instance type | `string` | `"t3.medium"` | no |
| <a name="input_linux_type"></a> [linux\_type](#input\_linux\_type) | type of linux instance | `string` | `"linux_amd64"` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | maximum number of prefect agents to be running at any given time | `number` | `1` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | minimum number of Prefect agents to be running at any given time | `number` | `1` | no |
| <a name="input_prefect_secret_key"></a> [prefect\_secret\_key](#input\_prefect\_secret\_key) | Key of AWS secrets manager secret for Prefect API key | `string` | `"key"` | no |
| <a name="input_prefect_secret_name"></a> [prefect\_secret\_name](#input\_prefect\_secret\_name) | ID of AWS secrets manager secret for Prefect API key | `string` | `"prefect-api-key"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->