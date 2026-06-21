# ci-terraform-iam

GitHub Actions OIDC provider and IAM role for Terraform in **ap-south-1**.

## Defaults (Gamya Couture)

| Setting | Value |
|---------|--------|
| Account ID | `085863558134` |
| Repository | `gvsharma/gamya-couture-infra` |
| Role name | `GitHubTerraformRole` |
| Trust | `repo:gvsharma/gamya-couture-infra:*` |
| Policy | `AdministratorAccess` (temporary — scope down later) |

## Standalone apply

```bash
cd github-oidc
terraform init && terraform apply
terraform output -raw role_arn
```

## GitHub secret

```
AWS_ROLE_ARN = <role_arn output>
```

## Tighten permissions later

Set `attach_administrator_access = false` and attach a custom scoped policy instead.
