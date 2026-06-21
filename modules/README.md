# Module Index

| Module | Path | Purpose |
|--------|------|---------|
| S3 | `modules/s3` | Documents, backups, frontend, deploy artifacts |
| IAM | `modules/iam` | EC2 instance profile, GitHub OIDC CI/deploy roles |
| Security Groups | `modules/security-groups` | EC2 HTTP/HTTPS (no RDS rules) |
| Route53 | `modules/route53` | Hosted zone (prod) |
| Route53 Records | `modules/route53-records` | API A record → existing EC2 EIP |
| ACM | `modules/acm` | TLS cert with DNS validation (us-east-1 provider) |
| CloudWatch | `modules/cloudwatch` | Log groups, alarms, dashboard |

EC2 is **not** a Terraform module — existing instances are referenced via `data.aws_instance`.
