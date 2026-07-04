variable "project_name" {
  type        = string
  description = "Name of the project used for naming AWS resources."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, test, or prod)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the Virtual Private Cloud (VPC)."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for the private subnets."
}