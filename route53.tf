resource "aws_route53_zone" "main" {
  name = var.aws_domain_name
}

resource "aws_route53_record" "default" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.aws_domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.frontend.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.aws_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.frontend.public_ip]
}

resource "aws_acm_certificate" "public" {
  domain_name               = aws_route53_zone.main.name
  subject_alternative_names = ["*.${aws_route53_zone.main.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "public_dns_verify" {
  for_each = {
    for dvo in aws_acm_certificate.public.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.id
}

resource "aws_acm_certificate_validation" "public" {
  certificate_arn         = aws_acm_certificate.public.arn
  validation_record_fqdns = [for record in aws_route53_record.public_dns_verify : record.fqdn]
}