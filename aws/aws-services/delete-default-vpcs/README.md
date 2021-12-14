## Delete Default VPCs Script
Removes the default VPC across all AWS regions

#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| function_name | string | unique name of the lambda function | Optional | delete-default-vpcs |

#### Outputs:
None

#### Creates:
* Delete default VPCs - this python based lambda function removes all default VPCs (and associated resources) in all regions within AWS.  This will prevent resource sprawl in unmonitored networks within the AWS environment.

#### Usage:
```
module "delete_default_vpcs" {
  source      = "path/to/delete-default-vpcs"
}
```