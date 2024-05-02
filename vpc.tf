resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "blog-infra-vpc-main"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  availability_zone = var.aws_subnet_public.subnet_1a.availability_zone
  cidr_block = var.aws_subnet_public.subnet_1a.cidr_block

  map_public_ip_on_launch = true

  tags = {
    Name = var.aws_subnet_public.subnet_1a.name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "blog-infra-igw-main"
  }
}
