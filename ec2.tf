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

##############################################################
# alb
##############################################################
resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  security_groups = [
    aws_security_group.instance-main.id
  ]
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_dummy.id
  ]
}

resource "aws_alb_listener" "alb_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.public.arn

  default_action {
    target_group_arn = aws_lb_target_group.ec2_http.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ec2_http" {
  name     = "ec2-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.ec2_http.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}