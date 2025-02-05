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
  gateway_id             = aws_internet_gateway.main.id
  route_table_id         = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_public_1a" {
  subnet_id      = aws_subnet.subnets["public-1a"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_public_1c" {
  subnet_id      = aws_subnet.subnets["public-1c"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_private_1c" {
  subnet_id      = aws_subnet.subnets["private-1c"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_vpc_endpoint" "codedeploy" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.codedeploy"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  policy              = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private-1c"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "codedeploy-private-1c-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "codedeploy_commands_secure" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.codedeploy-commands-secure"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  policy              = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private-1c"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "codedeploy-commands-secure-private-1c-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private-1c"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "ssm-private-1c-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  policy = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private-1c"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "ssm-messages-private-1c-${local.name_suffix}"
  }
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

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  policy              = data.aws_iam_policy_document.ssm_vpc_endpoint.json

  subnet_ids = [
    aws_subnet.subnets["private-1c"].id
  ]

  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint.id
  ]

  tags = {
    Name = "logs-private-1c-${local.name_suffix}"
  }
}

resource "aws_security_group" "ssm_vpc_endpoint" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for SSM VPC endpoint"

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
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_lb" "web" {
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true

  security_groups = [
    aws_security_group.alb_web.id
  ]

  subnets = [
    aws_subnet.subnets["public-1a"].id,
    aws_subnet.subnets["public-1c"].id
  ]

  tags = {
    Name = "web-${local.name_suffix}"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "web"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "ec2_instance_web_server" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_server.id
}

resource "aws_lb_listener" "web_https" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.my_domain.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_security_group" "alb_web" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for ALB named web"

  dynamic "ingress" {
    for_each = local.security_gruop_alb_web
    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = ingress.value[2]
      cidr_blocks = ingress.value[3]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-web-${local.name_suffix}"
  }
}