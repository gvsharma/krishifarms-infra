# Architecture Decision Records (ADR)

Log of significant infrastructure decisions. Agents: add an entry when making non-trivial architectural choices.

---

## ADR-001: Reuse Gamya EC2 instead of provisioning new instance

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** KrishiFarms CRM needs compute. A dedicated EC2 adds ~$24/mo. Gamya Couture already runs on `i-0426cdc00ff15bfe9`.

**Decision:** Share the existing EC2. Isolate by directory (`/opt/krishifarms/`), Docker project name, local port, and nginx `server_name`.

**Consequences:**
- (+) No additional EC2 cost
- (+) Same VPC, EIP, SSM access
- (−) Resource contention on `t3.micro`
- (−) Blast radius if host fails
- (−) Must never conflict with Gamya on port 8080 or `default_server`

---

## ADR-002: PostgreSQL in Docker, not RDS

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** RDS adds ~$15+/mo for `db.t4g.micro`. Initial users: 3–10.

**Decision:** Run PostgreSQL 16 in Docker Compose with volume on EC2. Backup via `pg_dump` to S3.

**Consequences:**
- (+) Major cost savings
- (+) Simple dev/prod parity
- (−) No managed failover or automated RDS backups
- (−) Agent must never add `aws_db_instance` without explicit approval

---

## ADR-003: Terraform does not create EC2

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** EC2 already exists for Gamya. Creating another conflicts with cost and ownership.

**Decision:** Reference EC2 via `data.aws_instance` and variables. Terraform manages S3, IAM, Route53, ACM, CloudWatch, SG only.

**Consequences:**
- (+) No accidental instance replacement
- (−) Manual steps: attach IAM profile, SG, run bootstrap script

---

## ADR-004: Shared AWS account with Gamya Couture

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** Same operator, same AWS account `085863558134`.

**Decision:** Separate state bucket (`krishifarms-terraform-state`) and IAM role (`KrishiFarmsGitHubTerraformRole`). Reuse OIDC provider and DynamoDB lock table.

**Consequences:**
- (+) No second AWS account overhead
- (−) IAM and lock table shared — naming discipline required

---

## ADR-005: Gamya-style GitHub OIDC CI/CD

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** `gamya-couture-infra` has working OIDC Terraform CI and SSM backend deploy.

**Decision:** Copy module pattern: `ci-terraform-iam`, `ci-backend-deploy-iam`, `backend-deploy-s3`. Dev auto-applies on push to `main`.

**Consequences:**
- (+) Proven pattern, no long-lived AWS keys in GitHub
- (−) Bootstrap must run before CI works
- (−) Requires GitHub `development` environment for apply approval

---

## ADR-006: AGENTS.md + Cursor rules for agentic IDE support

**Date:** 2026-06-21  
**Status:** Accepted  

**Context:** Repo maintained with Cursor and future AI agents. Context was re-discovered each session.

**Decision:** Maintain `AGENTS.md`, `docs/` index, architecture docs, CHANGELOG, ADRs, and `.cursor/rules/` requiring doc updates on every change.

**Consequences:**
- (+) Agents work safely without rediscovering constraints
- (−) Documentation debt if agents skip checklist (mitigated by Cursor rule)

---

## Template for new ADRs

```markdown
## ADR-00N: Title

**Date:** YYYY-MM-DD  
**Status:** Proposed | Accepted | Superseded by ADR-00X  

**Context:** …  
**Decision:** …  
**Consequences:** …  
```
