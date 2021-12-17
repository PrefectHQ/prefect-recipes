variable "environment" {
  type        = string
  description = "SDLC stage"
  default     = "dev"
}
variable "instance_type" {
  type        = string
  description = "AWS instance type, default requirement is t2.medium"
  default     = "t2.medium"
}
variable "ami_id" {
  type        = string
  description = "AMI to launch the EC2 instance from"
}
variable "linux_type" {
  type        = string
  description = "Type of linux instance"
  default     = "linux_amd64"
}
variable "key_name" {
  type        = string
  description = "ssh key name to use to connect to your airbyte instance"
}
variable "volume_size" {
  type        = number
  description = "size of volume to attach to airbyte instance; default requirement is 30GB"
  default     = 30
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the airbyte instance into"
}
variable "subnet_ids" {
  type        = list(string)
  description = "IDs of subnet to deploy airbyte instance into"
}
variable "ingress_cidrs" {
  type        = list(string)
  description = "list of cidr ranges to allow ssh access to your airbyte instance"
}
variable "min_capacity" {
  type        = number
  description = "minimum number of Prefect agents to be running at any given time"
  default     = 1
}
variable "max_capacity" {
  type        = number
  description = "maximum number of prefect agents to be running at any given time"
  default     = 1
}
variable "desired_capacity" {
  type        = number
  description = "desired number of prefect agents to be running at any given time"
  default     = 1
}