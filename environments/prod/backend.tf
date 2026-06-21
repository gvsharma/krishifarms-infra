terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket         = "krishifarms-terraform-state"
    key            = "infra/prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
