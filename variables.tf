#############################################################
# Provider
#############################################################
variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}
variable "aws_session_token" {
  type = string
}
variable "aws_region" {
  type = string
}

#############################################################
# CloudWatch
#############################################################
variable "cloudwatch-total-billing" {
  type    = number
  default = 8
}

#############################################################
# Dynamo
#############################################################
variable "aws_dynamo_locks_name" {
  type = string
}

#############################################################
# S3
#############################################################
variable "aws_s3_bucket_name" {
  type = string
}
variable "aws_s3_bucket_key" {
  type = string
}
variable "aws_s3_bucket_region" {
  type = string
}

#############################################################
# VPC
#############################################################
variable "aws_subnet_public" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
  default = {
    subnet_1a = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-northeast-1a"
      name              = "blog-infra-subnet-public"
    }
  }
}

