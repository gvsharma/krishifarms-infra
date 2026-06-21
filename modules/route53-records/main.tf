resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = var.api_fqdn
  type    = "A"
  ttl     = 300
  records = [var.ec2_public_ip]
}

resource "aws_route53_record" "web" {
  count = var.create_web_record && var.web_target != "" ? 1 : 0

  zone_id = var.zone_id
  name    = var.web_fqdn != "" ? var.web_fqdn : var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [var.web_target]
}
