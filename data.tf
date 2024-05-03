data "aws_instance" "main" {
  instance_id = aws_instance.main.id

  filter {
    name   = "tag:Name"
    values = ["blog-infra-instance-main"]
  }
}