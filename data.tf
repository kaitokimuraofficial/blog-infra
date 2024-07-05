data "aws_instance" "main" {
  instance_id = aws_instance.frontend.id

  filter {
    name   = "tag:Name"
    values = ["blog-infra-instance-frontend"]
  }
}

data "aws_caller_identity" "self" {}