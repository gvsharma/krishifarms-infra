output "api_fqdn" {
  value = var.api_fqdn
}

output "api_record_fqdn" {
  value = aws_route53_record.api.fqdn
}
