resource "aws_security_group" "ec2" {
  name_prefix = "${var.name_prefix}-ec2-"
  description = "KrishiFarms CRM application host (HTTP/HTTPS)."
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
    Tier = "app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  for_each = toset(var.web_ingress_cidr_blocks)

  security_group_id = aws_security_group.ec2.id
  description       = "HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ec2_https" {
  for_each = toset(var.web_ingress_cidr_blocks)

  security_group_id = aws_security_group.ec2.id
  description       = "HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh_admin" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.ec2.id
  description       = "SSH from admin IP only"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Outbound for Docker, updates, S3, APIs"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
