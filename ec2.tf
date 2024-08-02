##############################################################
# SSH key
##############################################################
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/ec2-keypair.pub")
}

##############################################################
# EC2 instance
##############################################################
resource "aws_instance" "frontend" {
  ami                         = "ami-03350e4f182961c7f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [
    aws_security_group.instance_main.id
  ]

  user_data = file("scripts/frontend-init.sh")

  tags = {
    Name = "blog-infra-instance-frontend"
  }
}
