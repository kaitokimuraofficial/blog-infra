resource "aws_s3_bucket" "main" {
  bucket = var.s3_main_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.s3_main_bucket_name}-${local.name_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "for_s3_main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.for_s3_main.json
}

data "aws_iam_policy_document" "for_s3_main" {
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
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}

resource "aws_db_instance" "data_storage_mysql" {
  allocated_storage             = 10
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rdb_password_encryption.id
  username                      = "admin"
  skip_final_snapshot           = true
  db_subnet_group_name          = aws_db_subnet_group.data_storage_mysql.name

  vpc_security_group_ids = [
    aws_security_group.rdb_instance.id
  ]

  tags = {
    Name = "data-storage-mysql-${local.name_suffix}"
  }
}

resource "aws_db_subnet_group" "data_storage_mysql" {
  subnet_ids = [
    aws_subnet.subnets["public-1a"].id,
    aws_subnet.subnets["private-1c"].id,
  ]

  tags = {
    Name = "data-storage-mysql-${local.name_suffix}"
  }
}

resource "aws_security_group" "rdb_instance" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for RDB instance"

  ingress {
    description = "MySQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rdb-instance-${local.name_suffix}"
  }
}