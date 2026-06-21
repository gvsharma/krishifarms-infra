# Existing EC2 is referenced via data.aws_instance.app — Terraform does NOT create EC2.
#
# Post-apply manual steps:
# 1. Attach IAM instance profile from output ec2_instance_profile_name
# 2. Attach security group from output ec2_security_group_id
# 3. Run bootstrap script on EC2 (see scripts/bootstrap/install.sh)
#
# Optional: import Route53 zone if it already exists:
#   terraform import 'module.route53[0].aws_route53_zone.this' Z1234567890ABC
