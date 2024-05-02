resource "aws_dynamodb_table" "locks" {
  name         = var.aws_dynamo_locks_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}