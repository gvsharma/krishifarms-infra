# Documentation Index

> **Start here** if you are a human or an AI agent new to this repo.

## Primary entry points

| Document | Audience | Purpose |
|----------|----------|---------|
| **[../AGENTS.md](../AGENTS.md)** | Cursor, Copilot, Claude, any agent | **Read first.** Constraints, AWS constants, safe edits, anti-patterns |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Engineers + agents | Full system design, data flows, component details |
| **[DOCUMENTATION.md](DOCUMENTATION.md)** | Contributors + agents | **How to keep docs updated** on every change |
| **[CHANGELOG.md](CHANGELOG.md)** | Everyone | Dated log of infra changes |
| **[DECISIONS.md](DECISIONS.md)** | Architects + agents | Why we chose X over Y (ADR log) |

## Operational runbooks

| Document | When to use |
|----------|-------------|
| [SHARED_EC2.md](SHARED_EC2.md) | Gamya + KrishiFarms on one EC2 |
| [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) | CI/CD setup and troubleshooting |
| [EC2_IMPORT.md](EC2_IMPORT.md) | Adopt / attach to existing EC2 |
| [RUNBOOK.md](RUNBOOK.md) | Backups, deploy, incidents |
| [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md) | File-level repo map |

## Cursor / agent rules

| File | Purpose |
|------|---------|
| [../.cursor/rules/krishifarms-infra.mdc](../.cursor/rules/krishifarms-infra.mdc) | Core repo constraints (always on) |
| [../.cursor/rules/documentation-maintenance.mdc](../.cursor/rules/documentation-maintenance.mdc) | **Update docs on every change** (always on) |

## Related repositories

| Repo | Role |
|------|------|
| `gvsharma/krishifarms-infra` | **This repo** — Terraform, Docker, scripts, CI |
| `gvsharma/krishifarms-crm` | FastAPI application |
| `gvsharma/gamya-couture-infra` | Reference pattern; shared AWS account + EC2 |

## Documentation maintenance rule

**Every infra change must update documentation in the same PR/commit.**

See [DOCUMENTATION.md](DOCUMENTATION.md) for the checklist agents must follow.
