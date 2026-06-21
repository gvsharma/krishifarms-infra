# Folder Structure Reference

Every top-level directory and its purpose.

## `bootstrap/`

One-time Terraform stack that creates the remote state S3 bucket and DynamoDB lock table. Run once per AWS account before any environment apply.

| File | Purpose |
|------|---------|
| `backend.tf` | Local backend for bootstrap itself |
| `s3.tf` | Versioned, encrypted state bucket with deny-insecure-transport policy |
| `dynamodb.tf` | `terraform-locks` table for state locking |
| `variables.tf` | Bucket name, region |
| `outputs.tf` | Bucket and table names for environment `backend.tf` |
| `terraform.tfvars.example` | Example configuration |

## `global/`

Shared tagging module consumed by all environments via `module "tags"`.

## `github-oidc/`

Standalone stack for GitHub OIDC provider and Terraform CI role (optional if using bootstrap OIDC).

## `environments/{dev,qa,prod}/`

Each environment is an independent Terraform root module with its own state key:

| File | Purpose |
|------|---------|
| `backend.tf` | S3 remote backend configuration |
| `providers.tf` | AWS provider `ap-south-1` + alias `us-east-1` for ACM/CloudFront |
| `variables.tf` | Environment-specific inputs |
| `locals.tf` | Computed FQDNs, name prefix |
| `main.tf` | Module composition |
| `outputs.tf` | DNS names, bucket names, IAM role ARNs |
| `data.tf` | Data sources for existing EC2 (prod) |
| `import.tf` | Import blocks for adopting existing resources |
| `ci.tfvars` | Non-secret defaults for GitHub Actions |
| `terraform.tfvars.example` | Operator copy template |

**Prod** references existing EC2 via `data.aws_instance.app` — Terraform does **not** create EC2.

## `modules/`

Reusable Terraform modules (see module READMEs).

## `docker/`

Docker Compose manifests and Nginx configs deployed to `/opt/krishifarms/` on EC2.

## `scripts/`

Operational shell scripts copied to EC2 during bootstrap.

## `.github/workflows/`

CI/CD pipelines for Terraform and application deploy.

## `docs/`

Runbooks and operational documentation.
