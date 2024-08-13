resource "aws_acm_certificate" "my_domain" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]

  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}"
  }
}