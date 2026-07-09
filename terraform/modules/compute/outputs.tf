output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host."
}

output "app_launch_template_id" {
  value       = aws_launch_template.app.id
  description = "ID of the unified application launch template"
}

output "app_instance_id" {
  value       = aws_instance.app.id
  description = "ID of the standalone app instance used for AMI baking"
}

output "grafana_instance_id" {
  value       = aws_instance.grafana.id
  description = "ID of the Grafana instance"
}