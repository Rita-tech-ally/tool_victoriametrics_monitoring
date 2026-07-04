output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host."
}

output "vminsert_instance_id" {
  value       = aws_instance.vminsert.id
  description = "ID of the vminsert standalone instance"
}

output "vmselect_instance_id" {
  value       = aws_instance.vmselect.id
  description = "ID of the vmselect standalone instance"
}

output "ingestion_launch_template_id" {
  value       = aws_launch_template.ingestion.id
  description = "ID of the ingestion launch template"
}

output "query_launch_template_id" {
  value       = aws_launch_template.query.id
  description = "ID of the query launch template"
}