# GitHub Actions — Terraform CI/CD (dev only)

Workflow: [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml)

| Setting | Value |
|---------|--------|
| Environment | **dev** |
| Stack path | `environments/dev` |
| AWS account | `085863558134` (same as Gamya Couture) |
| Region | `ap-south-1` |
| State key | `infra/dev/terraform.tfstate` |
| State bucket | `krishifarms-terraform-state` |
| Lock table | `terraform-locks` (shared with Gamya) |
| Role ARN | `vars.AWS_ROLE_ARN` or fallback `KrishiFarmsGitHubTerraformRole` |
| GitHub Environment | `development` |

**Prod (`environments/prod`) is not deployed by CI** — manual workflow only.

## Events

| Event | Action |
|-------|--------|
| PR → `main` | Plan only |
| Push → `main` | Plan + auto-apply dev |
| Manual + `apply=false` | Plan only |
| Manual + `apply=true` | Plan + apply dev (requires **development** approval) |

## Setup checklist

1. Apply `bootstrap/` with `enable_github_actions = true` (OIDC provider likely already exists from Gamya — set `create_github_oidc_provider = false`)
2. Set GitHub repo variable **`AWS_ROLE_ARN`** = `arn:aws:iam::085863558134:role/KrishiFarmsGitHubTerraformRole`
3. Create GitHub Environment **`development`** with required reviewers
4. Update `environments/dev/ci.tfvars` with shared Gamya EC2 `instance_id`, EIP, `vpc_id`
5. (Optional) Set secret **`KRISHIFARMS_GH_TOKEN`** — PAT with `repo` on `gvsharma/krishifarms-crm` so Terraform syncs deploy vars after apply
6. Merge PR → verify **Terraform / Plan (dev)** runs
7. Push to `main` or manual apply → dev stack + backend deploy IAM created

## Backend deploy (krishifarms-crm repo)

After dev apply, Terraform outputs `backend_deploy_github_setup`. Copy to **`gvsharma/krishifarms-crm`** or let Terraform/gh sync set:

| Setting | Purpose |
|---------|---------|
| Secret `AWS_BACKEND_DEPLOY_ROLE_ARN` | OIDC role for SSM deploy |
| Variable `DEPLOY_BUCKET` | S3 bucket for deploy metadata |
| Variable `EC2_INSTANCE_ID` | Shared Gamya EC2 |
| Variable `EC2_HOST` | Elastic IP |
| Variable `HEALTH_CHECK_URL` | e.g. `http://127.0.0.1:8082/health` (dev) |

Deploy workflow template: [`examples/github-workflows/deploy-backend.yml`](../examples/github-workflows/deploy-backend.yml)

## Shared EC2

Dev Terraform targets the **same EC2 as Gamya**. KrishiFarms dev listens on **8082**; prod on **8081**; Gamya on **8080**. See [SHARED_EC2.md](SHARED_EC2.md).

## Stale state lock

```bash
cd environments/dev
terraform force-unlock <LOCK_ID>
```

Then re-run the GitHub Actions workflow.
