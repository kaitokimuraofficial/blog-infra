resource "aws_route53_zone" "my_domain" {
  name = var.domain_name
}

resource "aws_route53domains_registered_domain" "my_domain" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.my_domain.name_servers
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_record" "my_domain" {
  for_each = {
    for dvo in aws_acm_certificate.my_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.my_domain.zone_id
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_domain.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.web.dns_name]
}