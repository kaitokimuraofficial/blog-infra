#############################################################
# BACKEND
#############################################################
variable "s3_backend_bucket_name" {
  type        = string
  description = "The name of the S3 bucket storing backend"
}

variable "s3_main_bucket_name" {
  type        = string
  description = "The name of the S3 bucket named main"
}

variable "dynamodb_lock_name" {
  type        = string
  description = "The name of the DynamoDB table storing lock"
}


#############################################################
# CLOUDWATCH
#############################################################
variable "total_billing" {
  type        = number
  description = "The number of total billing CloudWatch"
  default     = 8
}


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
    public-1a = {
      availability_zone       = "ap-northeast-1a"
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true
      name                    = "public-1a"
    },
    public-1c = {
      availability_zone       = "ap-northeast-1c"
      cidr_block              = "10.0.2.0/24"
      map_public_ip_on_launch = true
      name                    = "public-1c"
    },
    private-1c = {
      availability_zone       = "ap-northeast-1c"
      cidr_block              = "10.0.4.0/24"
      map_public_ip_on_launch = false
      name                    = "private-1c"
    }
  }
}


#############################################################
# ROUTE 53
#############################################################
variable "domain_name" {
  description = "The domain name of my website"
  type        = string
}