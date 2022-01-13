# State Management Module
Deploy infrastructure to host future terraform state files

#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| bucket_name | string | unique name to label the S3 bucket | Required | none |

#### Outputs: 
None

#### Creates:
* S3 bucket with versioning enabled to host Terraform state files
* DynamoDB table to handle file locking to ensure no race conditions with the state files

#### Usage:
```
module "state_management" {
  source      = "path/to/state-management"

  bucket_name = "name-of-bucket"
}
```