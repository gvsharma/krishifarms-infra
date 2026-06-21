# KrishiFarms CRM Infrastructure

Production Terraform, Docker Compose, and GitHub Actions for KrishiFarms CRM on AWS (`ap-south-1`).

| Item | Value |
|------|-------|
| Region | `ap-south-1` (Mumbai) |
| Terraform | `>= 1.9.0` |
| Naming prefix | `krishifarms-{env}` |
| State bucket | `krishifarms-terraform-state` |

## Repository layout

```
krishifarms-infra/
├── README.md
├── bootstrap/                    # One-time: S3 state + DynamoDB lock table
├── global/                       # Shared default tags
├── github-oidc/                  # GitHub Actions → AWS OIDC trust
├── environments/
│   ├── dev/                      # Dev stack (scheduled EC2 via scripts)
│   ├── qa/                       # QA stack
│   └── prod/                     # Prod — reuses existing EC2 (import/data source)
├── modules/
│   ├── s3/                       # Documents, backups, frontend, deploy artifacts
│   ├── iam/                      # EC2 role, CI deploy roles, GitHub OIDC policies
│   ├── route53/                  # Hosted zone
│   ├── route53-records/          # DNS A/CNAME records
│   ├── acm/                      # TLS certificates (us-east-1 for CloudFront)
│   ├── cloudwatch/               # Log groups, alarms, dashboard
│   └── security-groups/          # EC2 security group (no RDS)
├── docker/
│   ├── docker-compose.yml        # Base stack
│   ├── docker-compose.{dev,qa,prod}.yml
│   └── nginx/                    # Container + host nginx templates
├── scripts/
│   ├── bootstrap/                # EC2 first-run setup
│   ├── ssl/                      # Certbot / Let's Encrypt
│   ├── backup/                   # PostgreSQL → S3
│   └── deploy/                   # SSM / SSH deploy helper
├── .github/workflows/
│   ├── terraform.yml             # Infra CI (dev auto-apply)
│   ├── terraform-qa.yml
│   ├── terraform-prod.yml
│   └── deploy-backend.yml        # Build, test, deploy API
└── docs/
    ├── FOLDER_STRUCTURE.md
    ├── EC2_IMPORT.md
    └── RUNBOOK.md
```

## Quick start

```bash
# 1. Bootstrap remote state (once)
cd bootstrap && cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply

# 2. Configure prod (existing EC2)
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Set existing_ec2_instance_id, domain_name, vpc_id

terraform init
terraform plan
terraform apply

# 3. Bootstrap EC2 host (once per instance)
aws ssm start-session --target <instance-id>
sudo bash /opt/krishifarms/scripts/bootstrap/install.sh
```

See [docs/EC2_IMPORT.md](docs/EC2_IMPORT.md) and [docs/RUNBOOK.md](docs/RUNBOOK.md).
