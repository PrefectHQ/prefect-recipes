variable "instance_type" {
  type        = string
  description = "AWS instance type"
  default     = "t3.medium"
}
variable "ami_id" {
  type        = string
  description = "AMI to launch the EC2 instance from"
}
variable "environment" {
  type        = string
  description = "SDLC stage"
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the Prefect agent into"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets that will host the Prefect agent EC2 instance"
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