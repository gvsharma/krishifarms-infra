module "tags" {
  source = "../../global"

  environment       = var.environment
  auto_shutdown     = "true"
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
