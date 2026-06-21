module "tags" {
  source = "../../global"

  environment       = var.environment
  project           = var.project
  owner             = var.owner
  auto_shutdown     = "false"
  cost_optimization = "enabled"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.common_tags
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = module.tags.common_tags
  }
}

provider "github" {
  owner = split("/", var.github_backend_repository)[0]
  token = var.github_token
}
