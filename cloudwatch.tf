resource "aws_cloudwatch_metric_alarm" "total-billing" {
  alarm_description   = "This metric monitors if total billing is over 8 USD or not."
  alarm_name          = "total-billing"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  provider            = aws.us
  statistic           = "Maximum"
  period              = "21600"
  threshold           = var.cloudwatch-total-billing
}