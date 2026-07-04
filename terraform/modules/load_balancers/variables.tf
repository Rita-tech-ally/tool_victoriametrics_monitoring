variable "project_name" {
  type        = string
  description = "Name of the project used for naming AWS resources."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, test, or prod)."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the load balancer will be deployed."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs where the load balancer will be deployed."
}

variable "sg_alb_id" {
  type        = string
  description = "ID of the security group attached to the Application Load Balancer (ALB)."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for the ASGs"
}

variable "vminsert_instance_id" {
  type        = string
  description = "ID of the standalone vminsert instance"
}

variable "vmselect_instance_id" {
  type        = string
  description = "ID of the standalone vmselect instance"
}

variable "ingestion_launch_template_id" {
  type        = string
  description = "ID of the ingestion launch template"
}

variable "query_launch_template_id" {
  type        = string
  description = "ID of the query launch template"
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