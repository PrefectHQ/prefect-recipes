# Private Network Module
Deploy private networking infrastructure

#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| vpc_name | string | common name to apply to the VPC and all subsequent resources | Required | none |
| environment | string | SDLC stage | Required | none |
| azs | list(string) | AWS availabiility zones to deploy VPC subnets into | Required | none |
| vpc_cidr | string | CIDR range to assign to VPC | Required | none |
| private_subnet_cidrs | list(string) | cCIDR range to assign to private subnets | Required | none |
| public_subnet_cidrs | list(string) | CIDR range to assign to public subnets | Required | none |

#### Outputs: 
| Output Name | Description |
|-------------|-------------|
| vpc_id | ID of the VPC |
| private_subnet_ids | list of IDs of the private subnets |
| public_subnet_ids | list of IDs of the public subnets |

#### Creates:
* Virtual Private Cloud (VPC) 
  * 2 private subnets and associated route tables
  * 2 public subnets and associated route tables
* Internet Gateway - allow inbound/outbound traffic to/from public subnets (inbound denied by security group)
* Nat Gateway - allow outbound traffic from private subnets
* Security Group - allow all outbound traffic, deny all inbound traffic
* VPC endpoints - allows communication between resources in the VPC and other AWS services to route over AWS privatelink keeping the communication private
  * S3
  * ECR
* Flow Log - logs basic network traffic data to a CWL group

#### Usage:
```
module "network" {
  source      = "path/to/network"

  vpc_name = "vpc-name"
  environment = "dev"

  azs = ["us-east-1b", "us-east-1c"]

  vpc_cidr = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.0.0/24","10.0.1.0/24"]
  public_subnet_cidrs = ["10.0.3.0/24","10.0.4.0/24"]
}
```