locals {
  name_suffix = "${var.aws_region}-${var.environment}"
}

locals {
  security_gruop_ingress_ec2_instance_web_server = [
    ["SSH", 22, 22, "tcp", ["0.0.0.0/0"]],
    ["HTTP", 80, 80, "tcp", ["0.0.0.0/0"]],
    ["HTTPS", 443, 443, "tcp", ["0.0.0.0/0"]],
  ]
}

locals {
  security_gruop_alb_web = [
    [80, 80, "tcp", ["0.0.0.0/0"]],
    [443, 443, "tcp", ["0.0.0.0/0"]],
  ]
}