## Prefect Agent on EC2
Deploy 1 or more EC2 instances within an Autoscaling Group that will host the Prefect agent

#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| instance_type | string | AWS instance type | Optional | t3.medium |
| ami_id | string | AMI to launch the EC2 instance from | Required | none |
| environment | string | SDLC stage | Required | none |
| vpc_id | string | ID of the VPC to deploy the Prefect agent into | Required | none |
| private_subnet_ids | list(string) | IDs of the subnets that will host the Prefect agent EC2 instance | Required | none |
| min_capacity | number | minimum number of Prefect agents to be running at any given time | Optional | 1 |
| max_capacity | number | maximum number of Prefect agents to be running at any given time | Optional | 1 |
| desired_capacity | number | desired number of Prefect agents to be running at any given time | Optional | 1 |

#### Outputs:
None

#### Creates:
* EC2 instance(s) bootstrapped with Docker, Prefect agent, and other neccessary configuration.  Launched in an autoscaling group with a security group that allows no inbound traffic and all outbound traffic by default
* IAM role, policys and instance profile that will allow the EC2 instance(s) hosting the Prefect agent to communicate with S3, ECR, Secret Manger and CloudWatch Logs. Also attaches the AWS managed SSM policy to allow for ssh access to the instance via SSM.

#### Usage:
```
module "prefect_agent" {
  source      = "path/to/prefect-agent-on-ec2"

  ami_id             = "ami-xxxxxxxxxxxxxxxxx"
  environment        = "dev"
  vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
  private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx","subnet-xxxxxxxxxxxxxxxxx"]
}
```