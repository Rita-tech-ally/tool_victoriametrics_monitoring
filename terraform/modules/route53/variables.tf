variable "create_route53" {
  type        = bool
  default     = true
  description = "Flag to enable or disable Route 53 resource creation."
}

variable "domain_name" {
  type        = string
  description = "The domain name for the hosted zone (e.g. yourdomain.com)."
}

variable "alb_dns_name" {
  type        = string
  description = "The DNS name of the ALB."
}

variable "alb_zone_id" {
  type        = string
  description = "The Zone ID of the ALB."
}
