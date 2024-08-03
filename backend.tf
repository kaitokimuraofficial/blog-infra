terraform {
  backend "s3" {
    key     = "global/s3/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}