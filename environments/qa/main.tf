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
  backup_retention_days = 30
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix        = local.name_prefix
  environment        = var.environment
  ec2_instance_id    = var.existing_ec2_instance_id
  log_retention_days = var.log_retention_days
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
  github_repository           = var.github_infra_repository
  github_backend_repository   = var.github_backend_repository
  ec2_instance_arn            = data.aws_instance.app.arn
  create_github_oidc_provider = var.create_github_oidc_provider
  cloudwatch_log_group_arns   = module.cloudwatch.log_group_arns
}

module "route53_records" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../../modules/route53-records"

  zone_id       = data.aws_route53_zone.root[0].zone_id
  domain_name   = var.domain_name
  api_fqdn      = local.api_fqdn
  ec2_public_ip = var.existing_ec2_public_ip
}
