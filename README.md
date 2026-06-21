# KrishiFarms CRM Infrastructure

Production Terraform, Docker Compose, and GitHub Actions for KrishiFarms CRM on AWS (`ap-south-1`).

> **For AI agents (Cursor, Copilot, etc.):** Read **[AGENTS.md](AGENTS.md)** first, then **[docs/INDEX.md](docs/INDEX.md)**.  
> **Doc maintenance is mandatory** on every change — see **[docs/DOCUMENTATION.md](docs/DOCUMENTATION.md)**.

| Item | Value |
|------|-------|
| Region | `ap-south-1` (Mumbai) |
| AWS account | `085863558134` (shared with Gamya Couture) |
| Terraform | `>= 1.9.0` |
| Naming prefix | `krishifarms-{env}` |
| State bucket | `krishifarms-terraform-state` |
| App repo | [gvsharma/krishifarms-crm](https://github.com/gvsharma/krishifarms-crm) |
| Reference infra | [gvsharma/gamya-couture-infra](https://github.com/gvsharma/gamya-couture-infra) |

---

## Architecture (shared EC2)

KrishiFarms runs on the **same EC2 as Gamya Couture** — no extra instance cost. Apps are isolated by **domain**, **port**, and **directory**.

```
Internet
   ├─► api.gamyacouture.com     → host nginx → :8080 → Gamya Spring Boot
   ├─► api.krishifarms.in       → host nginx → :8081 → Docker (FastAPI + Postgres + Redis)
   └─► S3 documents/backups     ◄── IAM role on shared EC2
```

| App | Host path | Port |
|-----|-----------|------|
| Gamya Couture | `/opt/gamya-couture/` | 8080 |
| KrishiFarms prod | `/opt/krishifarms/` | 8081 |
| KrishiFarms dev | `/opt/krishifarms/` | 8082 |
| KrishiFarms qa | `/opt/krishifarms/` | 8083 |

See [docs/SHARED_EC2.md](docs/SHARED_EC2.md) for full setup.

---

## Repository layout

```
krishifarms-infra/
├── AGENTS.md                     # ← AI/agent context (read this first)
├── README.md
├── bootstrap/                    # One-time: S3 state + DynamoDB + GitHub OIDC role
├── global/                       # Shared default tags
├── github-oidc/                  # Standalone OIDC stack (optional)
├── environments/
│   ├── dev/                      # CI auto-applies on push to main
│   ├── qa/                       # Manual apply
│   └── prod/                     # Manual apply; reuses existing EC2
├── modules/                      # s3, iam, route53, acm, cloudwatch, ci-*
├── docker/                       # Compose + nginx templates
├── scripts/                      # bootstrap, ssl, backup, deploy
├── examples/github-workflows/    # deploy-backend.yml → copy to CRM repo
├── .github/workflows/            # terraform.yml (dev CI)
└── docs/                         # Runbooks and guides
```

Module index: [modules/README.md](modules/README.md)

---

## Quick start

### 1. Bootstrap remote state (once per account)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

Creates `krishifarms-terraform-state` and `KrishiFarmsGitHubTerraformRole`.

### 2. Configure GitHub Actions (infra repo)

| Setting | Value |
|---------|-------|
| Variable `AWS_ROLE_ARN` | `arn:aws:iam::085863558134:role/KrishiFarmsGitHubTerraformRole` |
| Environment `development` | Required reviewers for apply |

See [docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md).

### 3. Deploy dev stack (CI or manual)

```bash
cd environments/dev
# ci.tfvars has shared EC2 values — edit if needed
terraform init
terraform plan -var-file=ci.tfvars
terraform apply -var-file=ci.tfvars
```

Or merge to `main` — CI applies dev automatically.

**Note:** Creating a branch in the GitHub UI does not trigger Actions. Push a commit to `main`, open a PR, or run **Actions → Terraform → Run workflow** manually.

### 4. Bootstrap KrishiFarms on shared Gamya EC2

```bash
aws ssm start-session --target i-0426cdc00ff15bfe9 --region ap-south-1

# Copy repo to /tmp/krishifarms-infra, then:
sudo SHARED_EC2=true API_DOMAIN=api.krishifarms.in NGINX_LOCAL_PORT=8081 \
  bash /tmp/krishifarms-infra/scripts/bootstrap/install.sh

sudo API_DOMAIN=api.krishifarms.in ADMIN_EMAIL=you@domain.com \
  bash /opt/krishifarms/scripts/ssl/setup-ssl.sh

/opt/krishifarms/scripts/compose-up.sh prod
```

### 5. Backend deploy (CRM repo)

Copy [examples/github-workflows/deploy-backend.yml](examples/github-workflows/deploy-backend.yml) to `krishifarms-crm/.github/workflows/deploy.yml`.

---

## Documentation

| Doc | Audience | Contents |
|-----|----------|----------|
| **[AGENTS.md](AGENTS.md)** | AI / agentic IDEs | **Start here** — constraints, constants, safe edits |
| **[docs/INDEX.md](docs/INDEX.md)** | All | Master index of every doc |
| **[docs/DOCUMENTATION.md](docs/DOCUMENTATION.md)** | Contributors + agents | **Update docs on every change** |
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | Engineers | Full system design + diagrams |
| **[docs/CHANGELOG.md](docs/CHANGELOG.md)** | All | Dated change log |
| **[docs/DECISIONS.md](docs/DECISIONS.md)** | Architects | ADR log (why we chose X) |
| [docs/SHARED_EC2.md](docs/SHARED_EC2.md) | Operators | Gamya + KrishiFarms coexistence |
| [docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md) | DevOps | CI/CD setup checklist |
| [docs/EC2_IMPORT.md](docs/EC2_IMPORT.md) | DevOps | Adopt existing EC2 |
| [docs/RUNBOOK.md](docs/RUNBOOK.md) | Operators | Backups, restore, incidents |
| [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | All | File-level map |

---

## Design constraints

- **Reuse existing EC2** — Terraform does not create EC2
- **No RDS, ECS, EKS, Aurora, OpenSearch**
- **PostgreSQL + Redis in Docker** on the shared host
- **Minimize cost** — shared EC2, no NAT/ALB
- **Terraform manages:** S3, IAM, Route53, ACM, CloudWatch, Security Groups

---

## CI/CD summary

| Workflow | Trigger | Target |
|----------|---------|--------|
| `terraform.yml` | PR / push `main` | `environments/dev` |
| `terraform-qa.yml` | Manual | `environments/qa` |
| `terraform-prod.yml` | Manual | `environments/prod` |
| `deploy-backend.yml` (in CRM repo) | Push `main` | SSM deploy to EC2 |

---

## License / ownership

Managed by Terraform. Owner tag: `Venkat`. Project tag: `krishifarms`.
