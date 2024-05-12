data "aws_route53_zone" "main" {
  name         = var.aws_domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.aws_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.main.public_ip]
}