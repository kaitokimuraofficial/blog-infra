terraform {
  backend "s3" {
    key            = "global/s3/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "blog-infra-lock"
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = var.dynamodb_lock_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "lock-${local.name_suffix}"
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.s3_backend_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.s3_backend_bucket_name}-${local.name_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket                  = aws_s3_bucket.backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "for_s3_backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.for_s3_backend.json
}

data "aws_iam_policy_document" "for_s3_backend" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.account_id]
    }

    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.backend.arn,
      "${aws_s3_bucket.backend.arn}/*",
    ]
  }
}