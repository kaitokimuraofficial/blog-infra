resource "aws_kms_key" "rdb_password_encryption" {
  description             = "KMS key for encrypting the password of the RDS instance data_storage_mysql"
  enable_key_rotation     = true
  deletion_window_in_days = 20

  tags = {
    Name = "rdb-password-encryption-${local.name_suffix}"
  }
}

resource "aws_kms_key_policy" "for_rdb_password_encryption" {
  key_id = aws_kms_key.rdb_password_encryption.id
  policy = data.aws_iam_policy_document.for_kms_key.json
}

data "aws_iam_policy_document" "for_kms_key" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.account_id]
    }

    actions = [
      "kms:*",
    ]

    resources = [
      "*"
    ]
  }
}