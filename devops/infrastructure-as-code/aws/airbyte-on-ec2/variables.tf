variable "instance_type" {
  type        = string
  description = "AWS instance type, default requirement is t2.large"
  default     = "t2.large"
}
variable "ami_id" {
  type        = string
  description = "AMI to launch the EC2 instance from"
  default     = ""
}
variable "environment" {
  type        = string
  description = "SDLC stage"
  default     = "dev"
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the airbyte instance into"
}
variable "subnet_ids" {
  type        = list(string)
  description = "IDs of subnets to deploy airbyte instance into"
}
variable "min_capacity" {
  type        = number
  description = "minimum number of Airbyte instances to be running at any given time"
  default     = 1
}
variable "max_capacity" {
  type        = number
  description = "maximum number of Airbyte instances to be running at any given time"
  default     = 1
}
variable "desired_capacity" {
  type        = number
  description = "desired number of Airbyte instances to be running at any given time"
  default     = 1
}
variable "linux_type" {
  type        = string
  description = "type of linux instance"
  default     = "linux_amd64"
}
variable "key_name" {
  type        = string
  description = "ssh key name to use to connect to your airbyte instance"
}
variable "ingress_cidrs" {
  type        = list(string)
  description = "list of cidr ranges to allow ssh access to your airbyte instance"
}
variable "custom_tags" {
  description = "custom tags which can be passed on to the AWS resources. they should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}