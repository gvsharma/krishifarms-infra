module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix             = local.name_prefix
  vpc_id                  = var.vpc_id
  enable_ssh              = false
  web_ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "s3" {
  source = "../../modules/s3"

  name_prefix           = local.name_prefix
  account_id            = data.aws_caller_identity.current.account_id
  force_destroy_buckets = var.force_destroy_buckets
  backup_retention_days = 14
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix        = local.name_prefix
  environment        = var.environment
  ec2_instance_id    = var.existing_ec2_instance_id
  log_retention_days = var.log_retention_days
}

module "backend_deploy_artifacts" {
  count  = var.enable_backend_ssm_deploy ? 1 : 0
  source = "../../modules/backend-deploy-s3"

  name_prefix = local.name_prefix
}

module "iam" {
  source = "../../modules/iam"

  name_prefix                 = local.name_prefix
  environment                 = var.environment
  documents_bucket_arn        = module.s3.documents_bucket_arn
  backups_bucket_arn          = module.s3.backups_bucket_arn
  deploy_bucket_arn           = module.s3.deploy_bucket_arn
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  ssm_parameter_prefix        = local.ssm_parameter_prefix
  github_repository           = ""
  github_backend_repository   = ""
  ec2_instance_arn            = data.aws_instance.app.arn
  create_github_oidc_provider = var.create_github_oidc_provider
  cloudwatch_log_group_arns   = module.cloudwatch.log_group_arns
  additional_iam_policy_arns = var.enable_backend_ssm_deploy ? [
    module.backend_deploy_artifacts[0].ec2_read_policy_arn,
  ] : []
}

module "ci_backend_deploy" {
  count  = var.enable_backend_ssm_deploy ? 1 : 0
  source = "../../modules/ci-backend-deploy-iam"

  name_prefix          = local.name_prefix
  github_repository    = var.github_backend_repository
  deploy_bucket_arn    = module.backend_deploy_artifacts[0].bucket_arn
  ec2_instance_arn     = data.aws_instance.app.arn
  create_oidc_provider = false
  rds_instance_arn     = null

  allowed_ref_subjects = [
    "repo:${var.github_backend_repository}:ref:refs/heads/main",
  ]
}

module "github_backend_deploy_config" {
  count  = var.enable_backend_ssm_deploy && local.github_token_configured ? 1 : 0
  source = "../../modules/github-backend-deploy-config"

  repository      = var.github_backend_repository
  deploy_role_arn = module.ci_backend_deploy[0].deploy_role_arn
  deploy_bucket   = module.backend_deploy_artifacts[0].bucket_name
  ec2_instance_id = var.existing_ec2_instance_id
  ec2_host        = var.existing_ec2_public_ip
}

module "route53_records" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../../modules/route53-records"

  zone_id       = data.aws_route53_zone.root[0].zone_id
  domain_name   = var.domain_name
  api_fqdn      = local.api_fqdn
  ec2_public_ip = var.existing_ec2_public_ip
}

data "aws_route53_zone" "root" {
  count = var.enable_custom_domain ? 1 : 0
  name  = var.domain_name
}
