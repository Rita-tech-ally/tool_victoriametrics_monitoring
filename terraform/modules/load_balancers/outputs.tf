output "ingestion_alb_dns" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the shared Application Load Balancer (ALB)."
}

output "query_alb_dns" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the shared Application Load Balancer (ALB)."
}

output "tg_vminsert_arn" {
  value       = aws_lb_target_group.vminsert.arn
  description = "ARN of the target group for the vminsert service."
}

output "tg_vmselect_arn" {
  value       = aws_lb_target_group.vmselect.arn
  description = "ARN of the target group for the vmselect service."
}