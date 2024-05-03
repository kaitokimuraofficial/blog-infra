resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/ec2-keypair.pub")
}

resource "aws_instance" "main" {
  ami                         = "ami-0bdd30a3e20da30a1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [aws_security_group.instance-main.id]

  user_data = file("scripts/instance-main.sh")

  tags = {
    Name = "blog-infra-instance-main"
  }
}