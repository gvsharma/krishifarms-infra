resource "github_actions_secret" "aws_backend_deploy_role_arn" {
  repository  = local.name
  secret_name = "AWS_BACKEND_DEPLOY_ROLE_ARN"
  value       = var.deploy_role_arn
}

resource "github_actions_variable" "deploy_bucket" {
  repository    = local.name
  variable_name = "DEPLOY_BUCKET"
  value         = var.deploy_bucket
}

resource "github_actions_variable" "ec2_instance_id" {
  repository    = local.name
  variable_name = "EC2_INSTANCE_ID"
  value         = var.ec2_instance_id
}

resource "github_actions_variable" "ec2_host" {
  repository    = local.name
  variable_name = "EC2_HOST"
  value         = var.ec2_host
}
