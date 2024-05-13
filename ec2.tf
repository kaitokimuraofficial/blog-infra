resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/ec2-keypair.pub")
}

resource "aws_instance" "frontend" {
  ami                         = "ami-01bef798938b7644d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [
    aws_security_group.instance-main.id
  ]

  user_data = file("scripts/frontend-init.sh")

  tags = {
    Name = "blog-infra-instance-frontend"
  }
}

resource "aws_instance" "backend" {
  ami                         = "ami-01bef798938b7644d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [
    aws_security_group.instance-main.id
  ]

  user_data = file("scripts/backend-init.sh")

  tags = {
    Name = "blog-infra-instance-backend"
  }
}