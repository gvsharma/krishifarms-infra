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
    ├── SHARED_EC2.md           # Gamya + KrishiFarms on same EC2
    ├── EC2_IMPORT.md
    └── RUNBOOK.md
```

## Architecture

**Default: shared EC2 with Gamya Couture** (no extra instance cost). KrishiFarms uses port **8081**; Gamya keeps **8080**. See [docs/SHARED_EC2.md](docs/SHARED_EC2.md).

```
Internet
   ├─► api.gamyacouture.com  → host nginx → :8080 → Gamya (existing)
   ├─► api.krishifarms.in    → host nginx → :8081 → Docker (FastAPI + Postgres + Redis)
   └─► S3 documents/backups ◄── IAM role (merged on shared EC2)
```

## Quick start

```bash
# 1. Bootstrap remote state (once)
cd bootstrap && cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply

# 2. Configure prod (same EC2 as Gamya)
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Set existing_ec2_instance_id = Gamya EC2 id

terraform init && terraform plan && terraform apply

# 3. Bootstrap on shared EC2 (port 8081 — does not touch Gamya)
aws ssm start-session --target <instance-id>
sudo SHARED_EC2=true API_DOMAIN=api.krishifarms.in \
  bash /tmp/krishifarms-infra/scripts/bootstrap/install.sh
/opt/krishifarms/scripts/compose-up.sh prod
```

See [docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md) and [docs/SHARED_EC2.md](docs/SHARED_EC2.md).
