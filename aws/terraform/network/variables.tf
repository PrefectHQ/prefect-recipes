variable "vpc_name" {
  type        = string
  description = "common name to apply to the VPC and all subsequent resources"
}
variable "environment" {
  type        = string
  description = "SDLC stage"
}
variable "azs" {
  type        = list(string)
  description = "AWS availabiility zones to deploy VPC subnets into"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR range to assign to VPC"
}
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR range to assign to private subnets"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR range to assign to public subnets"
}