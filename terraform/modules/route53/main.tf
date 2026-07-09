resource "aws_route53_zone" "primary" {
  count = var.create_route53 ? 1 : 0
  name  = var.domain_name
}

resource "aws_route53_record" "alb_alias" {
  count   = var.create_route53 ? 1 : 0
  zone_id = aws_route53_zone.primary[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "grafana" {
  count   = var.create_route53 ? 1 : 0
  zone_id = aws_route53_zone.primary[0].zone_id
  name    = "grafana.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
