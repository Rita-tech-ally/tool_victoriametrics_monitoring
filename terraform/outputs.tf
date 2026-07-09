output "bastion_public_ip" {
  value       = module.compute.bastion_public_ip
  description = "Use this IP to jump into private cluster instances"
}

output "ingestion_alb_dns" {
  value       = module.load_balancers.ingestion_alb_dns
  description = "Public ALB URL to push metrics (Traffic balances to internal private 8480)"
}

output "query_alb_dns" {
  value       = module.load_balancers.query_alb_dns
  description = "Public ALB URL to access Grafana Dashboards / Queries"
}

output "app_instance_id" {
  value       = module.compute.app_instance_id
  description = "ID of the standalone app instance used for AMI baking"
}