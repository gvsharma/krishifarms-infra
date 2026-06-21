# AGENTS.md — KrishiFarms CRM Infrastructure

> **Purpose of this file:** Give Cursor, Copilot, Claude Code, and other agentic IDEs full context to work safely in this repo without re-discovering architecture from scratch.

---

## What this repo is

**Repository:** `gvsharma/krishifarms-infra`  
**Role:** AWS infrastructure, Docker Compose deployment assets, operational scripts, and GitHub Actions CI for **KrishiFarms CRM**.

**Application repo (separate):** `gvsharma/krishifarms-crm` — FastAPI backend, Alembic, business logic.

**Reference infra (sibling pattern):** `gvsharma/gamya-couture-infra` — same AWS account, same EC2 host, similar CI/CD model.

---

## Hard constraints (never violate)

| Rule | Detail |
|------|--------|
| **No new EC2 by default** | Reuse existing instance (`data.aws_instance`). Do not add `aws_instance` unless user explicitly requests a second host. |
| **No RDS / Aurora** | PostgreSQL runs in Docker on EC2. |
| **No ECS / EKS / OpenSearch** | Docker Compose only on EC2. |
| **Shared EC2 with Gamya** | Gamya `:8080`, KrishiFarms prod `:8081`, dev `:8082`, qa `:8083`. Never use `default_server` for KrishiFarms nginx. |
| **Terraform allowed services** | S3, IAM, Route53, ACM, CloudWatch, Security Groups. EC2 is referenced, not provisioned. |
| **Cost first** | No NAT Gateway, ALB, or managed DB unless user explicitly approves. |
| **Secrets** | Never commit `terraform.tfvars`, `.env`, PATs, or AWS keys. `ci.tfvars` is committed (non-secret placeholders only). |

---

## AWS context (live values)

| Key | Value |
|-----|-------|
| Account ID | `085863558134` |
| Region | `ap-south-1` |
| State bucket | `krishifarms-terraform-state` |
| Lock table | `terraform-locks` (shared with Gamya) |
| Terraform CI role | `arn:aws:iam::085863558134:role/KrishiFarmsGitHubTerraformRole` |
| OIDC provider | Already exists from Gamya — always `create_oidc_provider = false` in bootstrap/dev |

### Shared EC2 (Gamya dev API host — also used for KrishiFarms)

| Key | Value |
|-----|-------|
| Instance ID | `i-0426cdc00ff15bfe9` |
| Name tag | `gamya-couture-dev-api` |
| Elastic IP | `13.232.200.243` |
| VPC ID | `vpc-0f2fb2f22b1c747e8` |
| Instance type | `t3.micro` |
| Gamya path | `/opt/gamya-couture/` |
| KrishiFarms path | `/opt/krishifarms/` |

---

## Port and domain map

| Traffic | Domain (target) | Host nginx → | Backend |
|---------|-------------------|--------------|---------|
| Gamya API | `api.gamyacouture.com` | `127.0.0.1:8080` | Spring Boot (existing) |
| KrishiFarms prod API | `api.krishifarms.in` | `127.0.0.1:8081` | Docker nginx → FastAPI |
| KrishiFarms dev API | `dev.api.krishifarms.in` | `127.0.0.1:8082` | Docker nginx → FastAPI |
| KrishiFarms qa API | `qa.api.krishifarms.in` | `127.0.0.1:8083` | Docker nginx → FastAPI |

Host nginx config: `/etc/nginx/conf.d/krishifarms.conf` (KrishiFarms only — do not overwrite Gamya config).

---

## Repository map (where to edit what)

```
bootstrap/              → One-time: S3 state bucket, DynamoDB lock, GitHub Terraform OIDC role
environments/dev/       → CI auto-applies on push to main (primary working stack)
environments/qa/        → Manual Terraform only
environments/prod/      → Manual Terraform only; Route53 zone + ACM
modules/                → Reusable Terraform (s3, iam, route53, acm, cloudwatch, ci-*)
docker/                 → Compose files + nginx templates (copied to EC2 at bootstrap)
scripts/bootstrap/      → EC2 first-run install.sh (SHARED_EC2=true)
scripts/deploy/         → deploy.sh, compose-up.sh, health-check.sh
scripts/backup/         → PostgreSQL pg_dump → S3
scripts/ssl/            → Certbot setup
.github/workflows/      → terraform.yml (dev CI), terraform-qa/prod (manual)
examples/               → deploy-backend.yml template for krishifarms-crm repo
docs/                   → Human + agent runbooks (SHARED_EC2, GITHUB_ACTIONS, RUNBOOK)
```

---

## Terraform state keys

| Environment | S3 key |
|-------------|--------|
| dev | `infra/dev/terraform.tfstate` |
| qa | `infra/qa/terraform.tfstate` |
| prod | `infra/prod/terraform.tfstate` |

**Apply order for new account:**

1. `bootstrap/` — creates state bucket + `KrishiFarmsGitHubTerraformRole`
2. `environments/dev/` — CI deploys this on merge to `main`
3. `environments/prod/` — manual after dev validated

---

## CI/CD flows

### Infra CI (`terraform.yml`)

```
PR → main     → terraform plan (dev only, no apply)
push → main    → terraform plan + apply (dev)
manual         → plan; apply if input apply=true + development environment approval
```

Uses `environments/dev/ci.tfvars` — **not** `terraform.tfvars`.

GitHub secrets/vars on **this repo**:

| Name | Purpose |
|------|---------|
| `AWS_ROLE_ARN` | OIDC role for Terraform (fallback baked in workflow) |
| `KRISHIFARMS_GH_TOKEN` | Optional PAT to sync deploy config to CRM repo |

### Backend deploy (app repo)

Template: `examples/github-workflows/deploy-backend.yml` → copy to `krishifarms-crm/.github/workflows/deploy.yml`

```
push main → pytest → docker build → GHCR push → S3 deploy.env → SSM → deploy.sh on EC2
```

Terraform dev apply creates IAM role + S3 bucket; outputs in `backend_deploy_github_setup`.

---

## Docker Compose on EC2

**Start prod (on shared EC2):**

```bash
/opt/krishifarms/scripts/compose-up.sh prod
```

**Compose project name:** `krishifarms` (isolated from Gamya containers).

**Services:** `postgres`, `redis`, `api` (FastAPI), `nginx` (container).

**Prod compose chain:**

```
docker-compose.yml + docker-compose.prod.yml + docker-compose.shared-ec2.yml
```

**Config on host:** `/opt/krishifarms/config/.env` (secrets) and `host.env` (ports/domains).

---

## What Terraform manages vs what is manual

| Managed by Terraform | Manual on EC2 |
|----------------------|---------------|
| S3 buckets (documents, backups, frontend, deploy) | `bootstrap/install.sh` first run |
| IAM instance profile (new role created) | Attach profile to existing EC2 |
| Security group (new SG created) | Attach SG to existing EC2 |
| Route53 records | Certbot SSL (`setup-ssl.sh`) |
| CloudWatch log groups + alarms | CloudWatch agent log merge with Gamya |
| GitHub OIDC deploy role | `docker compose up` |
| Backend deploy S3 bucket (dev) | Merge Gamya + KrishiFarms IAM on one instance profile |

---

## Common agent tasks

### Add a new S3 bucket

1. Edit `modules/s3/main.tf` + lifecycle/outputs
2. Wire in `environments/{dev,qa,prod}/main.tf`
3. Extend `modules/iam/ec2.tf` S3 policy if EC2 needs access
4. Run `terraform fmt -recursive` and validate dev stack

### Change KrishiFarms port

1. Update `docker/docker-compose.{prod,dev,qa}.yml`
2. Update `docker/config/host.env.example`
3. Update `scripts/bootstrap/install.sh` default `NGINX_LOCAL_PORT`
4. Update `environments/dev/ci.tfvars` `health_check_url`
5. Update host nginx template `docker/nginx/host-nginx.conf.template`
6. **Do not** change Gamya `:8080`

### Deploy infrastructure change

```bash
cd environments/dev
terraform init
terraform plan -var-file=ci.tfvars
# CI applies on merge to main, or manual apply with approval
```

### Debug failed GitHub Actions Terraform

1. Check state lock: `terraform force-unlock <id>` in `environments/dev`
2. Verify `AWS_ROLE_ARN` and bootstrap role exists
3. Read job summary for plan output

---

## Related documentation (read before large changes)

| Doc | When to read |
|-----|--------------|
| [docs/SHARED_EC2.md](docs/SHARED_EC2.md) | Any EC2, nginx, or port change |
| [docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md) | CI/CD, OIDC, GitHub vars |
| [docs/EC2_IMPORT.md](docs/EC2_IMPORT.md) | Adopting / attaching to existing EC2 |
| [docs/RUNBOOK.md](docs/RUNBOOK.md) | Backups, restore, incidents |
| [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | File-level map |

---

## Naming conventions

| Pattern | Example |
|---------|---------|
| Resource prefix | `krishifarms-dev`, `krishifarms-prod` |
| S3 bucket | `krishifarms-prod-documents-{account_id}` |
| SSM params | `/krishifarms/{env}/...` |
| CloudWatch logs | `/krishifarms/{env}/nginx/access` |
| Docker network | `krishifarms-net` |
| Compose project | `krishifarms` |

---

## Current implementation status

| Item | Status |
|------|--------|
| Repo scaffold + modules | Done (branch `feat/initial-infra-implementation`) |
| Shared EC2 design | Done |
| CI/CD workflows (Gamya pattern) | Done |
| Bootstrap apply in AWS | **Not run** — state bucket may not exist yet |
| Dev Terraform apply | **Not run** |
| EC2 bootstrap (`install.sh`) | **Not run** |
| SSL for `api.krishifarms.in` | **Not run** |
| CRM deploy workflow | Template only in `examples/` |
| Merge to `main` | **Pending** |

---

## Anti-patterns (do not do this)

- Creating `aws_instance` for KrishiFarms without explicit user approval
- Adding RDS, ECS, EKS, Aurora, OpenSearch modules
- Setting KrishiFarms nginx as `default_server` on shared EC2
- Binding KrishiFarms to port `8080` (conflicts with Gamya)
- Committing secrets or real passwords
- Running `terraform apply` on prod without user confirmation
- Modifying `/opt/gamya-couture/` or Gamya nginx configs from this repo's scripts
- Removing Gamya IAM policies when merging instance profiles

---

## Quick commands reference

```bash
# Validate dev stack locally
cd environments/dev && terraform init -backend=false && terraform validate

# Format all Terraform
terraform fmt -recursive

# SSM into shared EC2
aws ssm start-session --target i-0426cdc00ff15bfe9 --region ap-south-1

# Health checks on EC2
curl -s http://127.0.0.1:8080/health   # Gamya
curl -s http://127.0.0.1:8081/health   # KrishiFarms prod (after bootstrap)
curl -s http://127.0.0.1:8082/health   # KrishiFarms dev

# Bootstrap KrishiFarms on shared EC2 (once)
sudo SHARED_EC2=true API_DOMAIN=api.krishifarms.in NGINX_LOCAL_PORT=8081 \
  bash /tmp/krishifarms-infra/scripts/bootstrap/install.sh
```

---

## Branch and PR context

- **Active feature branch:** `feat/initial-infra-implementation`
- **Base branch:** `main` (empty / not yet merged)
- **3 commits:** initial infra → shared EC2 → CI/CD

When making changes, prefer small focused commits on a feature branch and open PR to `main`.
