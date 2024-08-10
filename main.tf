##############################################################
# COMPUTES
##############################################################
resource "aws_instance" "main" {
  ami                         = "ami-03350e4f182961c7f"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_main.name
  subnet_id                   = aws_subnet.subnets["private"].id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.aws_instance_main.id
  ]

  user_data = file("scripts/main_init.sh")

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

data "aws_instance" "main" {
  instance_id = aws_instance.main.id

  filter {
    name   = "tag:Name"
    values = ["main-${local.name_suffix}"]
  }
}

resource "aws_iam_role" "ec2_instance_main" {
  name               = "ec2_instance_blog_main"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2_instance_main.json
}

data "aws_iam_policy_document" "assume_role_ec2_instance_main" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_instance_main_ssm_mic" {
  role       = aws_iam_role.ec2_instance_main.name
  policy_arn = data.aws_iam_policy.policy_ssm_managed_instance_core.arn
}

data "aws_iam_policy" "policy_ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_instance_main.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_main" {
  name = "ec2_instance_blog_main"
  role = aws_iam_role.ec2_instance_main.name
}

##############################################################
# METRICS
##############################################################
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-${local.name_suffix}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 6
        height = 6

        properties = {
          metrics = [
            [
              "AWS/Billing",
              "EstimatedCharges",
            ]
          ]
          period = 2592000
          stat   = "Maximum"
          region = "us-east-1"
          title  = "Total Billing"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              data.aws_instance.main.id
            ]
          ]
          period = 300
          stat   = "Average"
          region = "ap-northeast-1"
          title  = "EC2 Instance CPU"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "total_billing" {
  alarm_description   = "This metric monitors if total billing is over 8 USD or not."
  alarm_name          = "total-billing"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  provider            = aws.us
  statistic           = "Maximum"
  period              = "21600"
  threshold           = var.cloudwatch_total_billing

  tags = {
    Name = "total-billing-${local.name_suffix}"
  }
}


##############################################################
# NETWORK
##############################################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_subnet" "subnets" {
  for_each = var.aws_subnets

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = "${each.value.name}-${local.name_suffix}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_route" "igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.main.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "subnet_public" {
  subnet_id      = aws_subnet.subnets["public"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_pivate" {
  subnet_id      = aws_subnet.subnets["private"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "aws_instance_main" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "aws-instance-main-${local.name_suffix}"
  }
}

resource "aws_ec2_instance_connect_endpoint" "aws_instance_main" {
  subnet_id          = aws_subnet.subnets["private"].id
  security_group_ids = [aws_security_group.eic.id]
  preserve_client_ip = false

  tags = {
    Name = "aws-instance-main-${local.name_suffix}"
  }
}

resource "aws_security_group" "eic" {
  vpc_id      = aws_vpc.main.id
  description = "EIC Security Group For main EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eic-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private"].id
  ]
  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "private-subnet-ssm-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private"].id
  ]
  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "private-subnet-ssm-messages-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private"].id
  ]
  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "private-subnet-ec2-messages-${local.name_suffix}"
  }
}

resource "aws_security_group" "ssm_vpc_endpoint" {
  vpc_id      = aws_vpc.main.id
  description = "Security Group For SSM VPC EndPoint"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-vpc-endpoint-${local.name_suffix}"
  }
}

data "aws_iam_policy_document" "ssm_vpc_endpoint" {
  statement {
    actions   = ["*"]
    resources = ["*"]
    effect    = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}


##############################################################
# IAM
##############################################################
resource "aws_ssm_document" "run_shell_deploy_ec2_main" {
  name          = "SSM-RunShell-deploy-to-EC2-main"
  document_type = "Session"
  content = jsonencode({
    schemaVersion = "1.0"
    sessionType   = "Port"
    inputs = {
      runAsEnabled     = true
      runAsDefaultUser = "github_actions_user"
    }
    properties = {
      portNumber = "22"
    }
  })
}

data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "assume_role_gha" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.self.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:kaitokimuraofficial/blog:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "oidc_role_blog_deploy" {
  name               = "oidc-role-blog-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_role_gha.json
}

data "aws_iam_policy_document" "ssm_start_and_terminate" {
  statement {
    effect  = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:ap-northeast-1:${data.aws_caller_identity.self.account_id}:instance/${aws_instance.main.id}",
      aws_ssm_document.run_shell_deploy_ec2_main.arn,
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:*:session/*"]
  }
}

resource "aws_iam_role_policy" "ssm_start_and_terminate" {
  role   = aws_iam_role.oidc_role_blog_deploy.id
  policy = data.aws_iam_policy_document.ssm_start_and_terminate.json
}


##############################################################
# STORAGES
##############################################################
resource "aws_dynamodb_table" "locks" {
  name         = var.aws_dynamo_locks_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "locks-${local.name_suffix}"
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.aws_s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "backend-${var.aws_s3_bucket_name}-${local.name_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
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

data "aws_iam_policy_document" "s3" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.self.account_id}"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.backend.arn,
      "${aws_s3_bucket.backend.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type   = "Gateway"
  private_dns_enabled = false

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  route_table_ids = [
    aws_route_table.main.id
  ]

  tags = {
    Name = "s3-${local.name_suffix}"
  } 
}

resource "aws_kms_key" "main" {
  description             = "An main KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.subnets["public"].id, aws_subnet.subnets["private"].id]

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage             = 10
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.main.key_id
  username                      = "admin"
  skip_final_snapshot           = true
  vpc_security_group_ids        = [aws_security_group.db_instance.id]

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_security_group" "db_instance" {
  vpc_id = aws_vpc.main.id
  name   = "main_db_instance"

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
    Name = "db-instance-main-${local.name_suffix}"
  }
}
