resource "aws_instance" "web_server" {
  ami                         = "ami-03350e4f182961c7f"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.web_server.name
  subnet_id                   = aws_subnet.subnets["private-1c"].id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.ec2_instance_web_server.id
  ]

  user_data = file("scripts/init_web_server.sh")

  tags = {
    Name = "web-server-${local.name_suffix}"
  }
}

data "aws_instance" "web_server" {
  instance_id = aws_instance.web_server.id

  filter {
    name   = "tag:Name"
    values = ["web-server-${local.name_suffix}"]
  }
}

resource "aws_iam_role" "ec2_session_s3_logging_role" {
  name               = "ec2-session-s3-logging-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "ec2-session-s3-logging-${local.name_suffix}"
  }
}

resource "aws_iam_instance_profile" "web_server" {
  name = "web-server"
  role = aws_iam_role.ec2_session_s3_logging_role.name
}

resource "aws_security_group" "ec2_instance_web_server" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for EC2 instance named web_server"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "ec2-instance-web-server-${local.name_suffix}"
  }
}