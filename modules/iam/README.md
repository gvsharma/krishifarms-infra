# IAM — KrishiFarms CRM

| Role | Purpose |
|------|---------|
| `ec2` | Instance profile for existing EC2: S3, SSM params, CloudWatch logs |
| `terraform_ci` | GitHub OIDC → Terraform plan/apply |
| `backend_deploy` | GitHub OIDC → S3 upload + SSM SendCommand |
| `frontend_deploy` | GitHub OIDC → S3 frontend sync |

Attach `ec2_instance_profile_name` to your existing EC2 via AWS Console or CLI after apply.
