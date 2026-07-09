output "name_servers" {
  value       = var.create_route53 ? aws_route53_zone.primary[0].name_servers : []
  description = "Name servers for the Route 53 hosted zone."
}

output "domain_name" {
  value       = var.create_route53 ? var.domain_name : ""
  description = "The configured domain name."
}
