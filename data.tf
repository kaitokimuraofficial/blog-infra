data "aws_instance" "main" {
  instance_id = aws_instance.frontend.id

  filter {
    name   = "tag:Name"
    values = ["blog-infra-instance-frontend"]
  }
}