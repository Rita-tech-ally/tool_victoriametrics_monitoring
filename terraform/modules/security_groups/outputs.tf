output "sg_alb_id" { value = aws_security_group.alb.id }
output "sg_bastion_id" { value = aws_security_group.bastion.id }
output "sg_ingestion_id" { value = aws_security_group.ingestion.id }
output "sg_query_id" { value = aws_security_group.query.id }
output "sg_storage_id" { value = aws_security_group.storage.id }