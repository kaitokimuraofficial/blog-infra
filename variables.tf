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
# Dynamo
#############################################################
variable "aws_dynamo_locks_name" {
  type = string
}
