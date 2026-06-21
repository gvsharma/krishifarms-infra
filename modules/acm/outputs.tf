output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "certificate_arn_validated" {
  value = var.wait_for_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.this.domain_validation_options
}
