provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      project     = "blog-infra"
      environment = "dev"
    }
  }
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}