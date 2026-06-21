data "aws_caller_identity" "current" {}

data "aws_instance" "app" {
  instance_id = var.existing_ec2_instance_id
}
