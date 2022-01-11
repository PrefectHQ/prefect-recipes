## Airbyte on EC2
Deploys Airbyte on an EC2 instance in an autoscaling group and attaches an EBS volume to hold Airbyte configuration files

#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| instance_type | string | AWS instance type | optional | t2.medium |
| ami_id | string | AMI to launch the EC2 instance from | required | none |
| environment | string | SDLC stage | required | dev |
| vpc_id | string | ID of the VPC to deploy the airbyte instance into | required | none |
| subnet_id | string | ID of subnet to deploy airbyte instance into | required | none |
| min_capacity | number | minimum number of Airbyte instances to be running at any given time | optional | 1 |
| max_capacity | number | maximum number of Airbyte instances to be running at any given time | optional | 1 |
| desired_capacity | number | desired number of Airbyte instances to be running at any given time | optional | 1 |
| linux_type | string | type of linux instance | optional | linux_amd64 |
| key_name | string | ssh key name to use to connect to your airbyte instance | required | none |
| volume_size | number | size of volume to attach to airbyte instance | optional | 30 |
| ingress_cidrs | list(string) | list of cidr ranges to allow ssh access to your airbyte instance | required | none |

#### Outputs:
None

#### Creates:
* EBS volume to host Airbyte configuration files
* EC2 instance(s) bootstrapped with Docker, Airbyte, and other neccessary configuration.  Launched in an autoscaling group with a security group that allows ssh inbound traffic from a specified CIDR range and all outbound traffic by default
* IAM role, policys and instance profile that will allow the EC2 instance(s) hosting the Airbyte to communicate with CloudWatch Logs. Also attaches the AWS managed SSM policy to allow for ssh access to the instance via SSM.
* Lambda function that runs when the autoscaling group launches a new Airbyte instance.  Attaches EBS volume holding configuration files to Airbyte EC2
* IAM role and policies that allow the lambda function to interact with EC2 and cloudwatch logs

#### Usage:
```
module "airbyte" {
  source      = "path/to/airbyte-on-ec2"

  ami_id        = "ami-xxxxxxxxxxxxxxxxx"
  vpc_id        = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_id     = ["subnet-xxxxxxxxxxxxxxxxx"]
  key_name      = "key.pem"
  ingress_cidrs = ["10.0.0.0/16"]

}
```