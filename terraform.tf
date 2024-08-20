terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.61.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.5.0"
    }
  }
}