variable "project_name" {
  type        = string
  description = "Name of the project used for naming AWS resources."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, test, or prod)."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs."
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the existing EC2 Key Pair in AWS."
}

variable "ami_id_ingestion" {
  type        = string
  description = "AMI ID used for the ingestion nodes (vminsert and vmagent)."
}

variable "ami_id_query" {
  type        = string
  description = "AMI ID used for the query nodes (vmselect and vmalert)."
}

variable "ami_id_storage" {
  type        = string
  description = "AMI ID used for the storage nodes (vmstorage and Grafana)."
}

variable "bastion_ami_id" {
  type        = string
  description = "AMI ID used for the bastion host instance."
}

variable "sg_bastion_id" {
  type        = string
  description = "Security group ID for the bastion host."
}

variable "sg_ingestion_id" {
  type        = string
  description = "Security group ID for the ingestion nodes."
}

variable "sg_query_id" {
  type        = string
  description = "Security group ID for the query nodes."
}

variable "sg_storage_id" {
  type        = string
  description = "Security group ID for the storage nodes."
}
