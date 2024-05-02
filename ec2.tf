resource "aws_instance" "main" {
  ami           = "ami-0bdd30a3e20da30a1"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "blog-infra-instance-main"
  }
}