output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host."
}

output "app_launch_template_id" {
  value       = aws_launch_template.app.id
  description = "ID of the unified application launch template"
}

output "app_instance_id" {
  value       = try(aws_instance.app[0].id, "")
  description = "ID of the standalone app instance used for AMI baking"
}