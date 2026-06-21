# Non-sensitive defaults for GitHub Actions — DEV ONLY
# Same AWS account as Gamya Couture: 085863558134

aws_region     = "ap-south-1"
aws_account_id = "085863558134"
environment    = "dev"
project        = "krishifarms"
owner          = "Venkat"

domain_name = "krishifarms.in"

# Shared Gamya EC2 — replace with real values after: aws ec2 describe-instances
existing_ec2_instance_id = "REPLACE_WITH_GAMYA_EC2_ID"
existing_ec2_public_ip   = "REPLACE_WITH_GAMYA_EIP"
vpc_id                   = "REPLACE_WITH_GAMYA_VPC_ID"

force_destroy_buckets = true
log_retention_days    = 3

# Shared EC2 port map: Gamya 8080, KrishiFarms prod 8081, KrishiFarms dev 8082
nginx_local_port = 8082
health_check_url = "http://127.0.0.1:8082/health"

# Backend deploy: GitHub Actions → S3 → SSM → EC2 (Docker)
enable_backend_ssm_deploy   = true
github_backend_repository   = "gvsharma/krishifarms-crm"
create_github_oidc_provider = false

enable_custom_domain = true
