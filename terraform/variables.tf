variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region where all resources will be deployed."
}

variable "project_name" {
  type        = string
  default     = "victoria-metrics"
  description = "Name of the project used for naming AWS resources."
}

variable "environment" {
  type        = string
  default     = "prod"
  description = "Deployment environment (e.g., dev, test, or prod)."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the Virtual Private Cloud (VPC)."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "List of CIDR blocks for the public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  description = "List of CIDR blocks for the private subnets."
}

variable "ssh_key_name" {
  type        = string
  default     = "sakshi"
  description = "Name of the existing EC2 Key Pair in AWS."
}

variable "ami_id_ingestion" {
  type        = string
  default     = "ami-0326c8c1e2d6bf78c"
  description = "AMI ID used for the ingestion nodes (vminsert and vmagent)."
}

variable "ami_id_query" {
  type        = string
  default     = "ami-0326c8c1e2d6bf78c"
  description = "AMI ID used for the query nodes (vmselect and vmalert)."
}

variable "ami_id_storage" {
  type        = string
  default     = "ami-0326c8c1e2d6bf78c"
  description = "AMI ID used for the storage nodes (vmstorage and Grafana)."
}

variable "bastion_ami_id" {
  type        = string
  default     = "ami-0326c8c1e2d6bf78c"
  description = "AMI ID used for the bastion host instance."
}

variable "baston_ip_cidr" {
  type        = string
  description = "CIDR block for SSH access to the Bastion Host."
  default     = "0.0.0.0/0"
}

variable "ingestion_asg_desired" {
  type    = number
  default = 0
}

variable "ingestion_asg_min" {
  type    = number
  default = 0
}

variable "query_asg_desired" {
  type    = number
  default = 0
}

variable "query_asg_min" {
  type    = number
  default = 0
}