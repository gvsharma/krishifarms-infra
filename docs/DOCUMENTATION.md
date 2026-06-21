# Documentation Maintenance Guide

This repo is designed for **long-term use with Cursor and other agentic AI editors**. Documentation is not optional — it is part of every change.

---

## Golden rule

> **If you change behavior, architecture, ports, CI, AWS resources, or scripts — update the docs in the same commit.**

Agents: treat documentation updates as **required**, not follow-up work.

---

## Document map — what to update when

| You changed… | Update these files |
|--------------|-------------------|
| **Terraform module** | `modules/<name>/README.md`, `docs/ARCHITECTURE.md`, `docs/CHANGELOG.md`, `AGENTS.md` (if constraints/constants change) |
| **Environment stack** (`environments/*`) | `docs/ARCHITECTURE.md`, `ci.tfvars` comments, `docs/CHANGELOG.md` |
| **Docker Compose / nginx** | `docs/SHARED_EC2.md`, `docs/ARCHITECTURE.md`, `docker/config/host.env.example`, `AGENTS.md` port map |
| **Scripts** (`scripts/*`) | `docs/RUNBOOK.md`, `docs/EC2_IMPORT.md`, `AGENTS.md` quick commands |
| **GitHub Actions** | `docs/GITHUB_ACTIONS.md`, `AGENTS.md` CI section, `docs/CHANGELOG.md` |
| **AWS account / EC2 / VPC** | `environments/*/ci.tfvars`, `AGENTS.md` AWS context, `docs/ARCHITECTURE.md` |
| **Architecture decision** | `docs/DECISIONS.md` (new ADR entry) |
| **New folder / major restructure** | `docs/FOLDER_STRUCTURE.md`, `README.md`, `docs/INDEX.md` |
| **Implementation status** | `AGENTS.md` status table, `docs/CHANGELOG.md` |

---

## Agent checklist (every task)

Before marking work complete, verify:

- [ ] Read `AGENTS.md` at task start
- [ ] Identified which docs are affected by the change
- [ ] Updated `docs/CHANGELOG.md` with date + summary
- [ ] Updated technical docs (`ARCHITECTURE`, runbooks, or `AGENTS.md`) if behavior changed
- [ ] Added ADR to `docs/DECISIONS.md` if a non-obvious tradeoff was made
- [ ] Updated `AGENTS.md` **Current implementation status** if milestone completed
- [ ] Did not commit secrets (`terraform.tfvars`, `.env`, tokens)

---

## CHANGELOG format

Append to [CHANGELOG.md](CHANGELOG.md) under `[Unreleased]` or a dated section:

```markdown
## [Unreleased]

### Added
- Short description (#PR or commit context)

### Changed
- What changed and why

### Fixed
- Bug or CI fix
```

On release/merge to main, move `[Unreleased]` to a dated version heading.

---

## ADR format (DECISIONS.md)

When making a significant choice (e.g. shared EC2 vs dedicated, no RDS):

```markdown
## ADR-00N: Title

**Date:** YYYY-MM-DD  
**Status:** Accepted | Superseded  
**Context:** Problem statement  
**Decision:** What we chose  
**Consequences:** Pros, cons, follow-ups  
```

---

## AGENTS.md maintenance

`AGENTS.md` is the **single source of truth for AI agents**. Keep it:

- **Accurate** — AWS IDs, ports, role ARNs match reality
- **Actionable** — common tasks with file paths
- **Current** — status table reflects what's done vs pending
- **Concise** — deep detail lives in `docs/ARCHITECTURE.md`

When `AGENTS.md` exceeds ~400 lines, move new deep content to `docs/` and leave a summary + link in `AGENTS.md`.

---

## README.md maintenance

`README.md` is for **humans first**. Keep:

- Link to `AGENTS.md` and `docs/INDEX.md` at the top
- Quick start accurate
- No duplication of full architecture (link instead)

---

## Cursor rules

Project rules in `.cursor/rules/` enforce doc maintenance:

| Rule | File |
|------|------|
| Core infra constraints | `krishifarms-infra.mdc` |
| Doc update requirement | `documentation-maintenance.mdc` |

Do not remove or weaken these rules without explicit user approval.

---

## Review cadence

| When | Action |
|------|--------|
| Every PR | Reviewer/agent checks doc checklist |
| After AWS apply | Update status in `AGENTS.md`, `CHANGELOG.md` |
| After EC2 bootstrap | Update `RUNBOOK.md`, mark status done |
| Monthly | Scan `AGENTS.md` constants against live AWS (`aws ec2 describe-instances`, etc.) |

---

## Verifying docs against live AWS

```bash
# EC2 / VPC (update AGENTS.md + ci.tfvars if changed)
aws ec2 describe-instances --region ap-south-1 \
  --filters "Name=tag:Project,Values=gamya-couture" \
  --query 'Reservations[].Instances[].{Id:InstanceId,Ip:PublicIpAddress,Vpc:VpcId}'

# State bucket exists
aws s3 ls s3://krishifarms-terraform-state

# Terraform CI role exists
aws iam get-role --role-name KrishiFarmsGitHubTerraformRole
```

---

## Questions?

If unsure which doc to update, default to:

1. `docs/CHANGELOG.md` — always
2. `AGENTS.md` — if agents need new context
3. Most specific runbook in `docs/`
