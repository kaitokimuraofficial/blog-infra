output "s3_bucket_arn" {
  value       = aws_s3_bucket.backend.arn
  description = "The ARN of the S3 bucket storing backend"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "The name of the DynamoDB table storing locks"
}