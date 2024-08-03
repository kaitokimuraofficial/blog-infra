#############################################################
# CREDENTIALS
#############################################################
variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment to deploy (prod, dev or test)"
  default     = "dev"
}


#############################################################
# METRICS
#############################################################
variable "cloudwatch_total_billing" {
  type        = number
  description = "The number of total billing CloudWatch "
  default     = 8
}


#############################################################
# NETWORK
#############################################################
variable "aws_subnets" {
  type = map(object({
    availability_zone       = string
    cidr_block              = string
    map_public_ip_on_launch = bool
    name                    = string
  }))
  description = "The setings of VPC subnets"
  default = {
    public = {
      availability_zone       = "ap-northeast-1a"
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true
      name                    = "public"
    },
    private = {
      availability_zone       = "ap-northeast-1a"
      cidr_block              = "10.0.2.0/24"
      map_public_ip_on_launch = false
      name                    = "private"
    }
  }
}


#############################################################
# Route 53
#############################################################
variable "aws_domain_name" {
  type        = string
  description = "The domain name for AWS resources"
}


#############################################################
# STORAGES
#############################################################
variable "aws_dynamo_locks_name" {
  type        = string
  description = "The name of the DynamoDB table used for locking"
}

variable "aws_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to be created"
}