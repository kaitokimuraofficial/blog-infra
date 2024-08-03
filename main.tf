##############################################################
# COMPUTES
##############################################################
resource "aws_instance" "main" {
  ami                         = "ami-03350e4f182961c7f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnets["private"].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name

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

resource "aws_key_pair" "main" {
  public_key = file("~/.ssh/ec2-keypair.pub")

  tags = {
    Name = "main-${local.name_suffix}"
  }
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
          stat   = "Average"
          region = "us-east-1"
          title  = "Total billing"
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
# ROUTE 53
##############################################################
resource "aws_route53_zone" "main" {
  name = var.aws_domain_name
}

resource "aws_route53_record" "default" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.aws_domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.main.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.aws_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.main.public_ip]
}

resource "aws_acm_certificate" "public" {
  domain_name               = aws_route53_zone.main.name
  subject_alternative_names = ["*.${aws_route53_zone.main.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "public_dns_verify" {
  for_each = {
    for dvo in aws_acm_certificate.public.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.id
}

resource "aws_acm_certificate_validation" "public" {
  certificate_arn         = aws_acm_certificate.public.arn
  validation_record_fqdns = [for record in aws_route53_record.public_dns_verify : record.fqdn]
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
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "get_object" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
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

resource "aws_s3_bucket_policy" "get_object" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.get_object.json
}