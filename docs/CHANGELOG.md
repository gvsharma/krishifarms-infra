# Changelog

All notable infrastructure changes to **krishifarms-infra**.  
Agents: **append to [Unreleased] on every change** — see [DOCUMENTATION.md](DOCUMENTATION.md).

Format based on [Keep a Changelog](https://keepachangelog.com/).

---

## [Unreleased]

### Added
- `docs/INDEX.md` — master documentation index
- `docs/ARCHITECTURE.md` — full system architecture reference
- `docs/DOCUMENTATION.md` — doc maintenance guide for humans and agents
- `docs/DECISIONS.md` — architecture decision records (ADR-001–006)
- `docs/CHANGELOG.md` — this file
- `.cursor/rules/documentation-maintenance.mdc` — require doc updates on every change
- CI trigger documentation in `AGENTS.md` and `README.md`

### Changed
- Disable custom domain in dev/qa/prod `ci.tfvars` until Route53 hosted zone exists for `krishifarms.in`
- Bootstrap applied in AWS (2026-06-21): state bucket, lock table, GitHub OIDC role created
- Documented mandatory git workflow: feature branch → PR → merge to `main` for CI apply; never push directly to `main`
- Enhanced `AGENTS.md` as primary agent entry point
- Populated `environments/dev/ci.tfvars` and `prod/ci.tfvars` with live Gamya EC2 values

---

## [0.1.0] — 2026-06-21

### Added
- Initial Terraform modules: s3, iam, security-groups, route53, route53-records, acm, cloudwatch
- CI modules: ci-terraform-iam, ci-backend-deploy-iam, backend-deploy-s3, github-backend-deploy-config
- Environment stacks: dev, qa, prod
- Bootstrap: S3 state bucket, DynamoDB lock, GitHub Terraform OIDC role
- Docker Compose stack: FastAPI, PostgreSQL, Redis, nginx
- Scripts: bootstrap, ssl, backup, deploy, compose-up
- GitHub Actions: terraform.yml (dev), terraform-qa.yml, terraform-prod.yml
- Shared EC2 support with Gamya Couture (ports 8081–8083)
- `AGENTS.md`, `README.md`, runbooks (SHARED_EC2, GITHUB_ACTIONS, EC2_IMPORT, RUNBOOK)
- `.cursor/rules/krishifarms-infra.mdc`
- `examples/github-workflows/deploy-backend.yml` for krishifarms-crm repo

### Known pending
- Bootstrap `terraform apply` in AWS
- Dev/prod Terraform apply
- EC2 bootstrap (`install.sh`) on shared host
- SSL for `api.krishifarms.in`
- CRM deploy workflow copied to app repo
- Merge feature branch to `main`

---

## Version tags

| Version | Branch / milestone |
|---------|-------------------|
| 0.1.0 | `feat/initial-infra-implementation` — initial scaffold |

When merging to `main` and tagging releases, move `[Unreleased]` items to a dated version section.
