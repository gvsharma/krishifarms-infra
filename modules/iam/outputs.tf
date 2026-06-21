output "ec2_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_role_name" {
  value = aws_iam_role.ec2.name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2.arn
}

output "terraform_ci_role_arn" {
  value = length(aws_iam_role.terraform_ci) > 0 ? aws_iam_role.terraform_ci[0].arn : null
}

output "backend_deploy_role_arn" {
  value = length(aws_iam_role.backend_deploy) > 0 ? aws_iam_role.backend_deploy[0].arn : null
}

output "frontend_deploy_role_arn" {
  value = length(aws_iam_role.frontend_deploy) > 0 ? aws_iam_role.frontend_deploy[0].arn : null
}
