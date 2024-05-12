resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 6
        height = 6

        properties = {
          metrics = [
            [
              "AWS/Billing",
              "EstimatedCharges",
            ]
          ]
          period = 2592000
          stat   = "Average"
          region = "us-east-1"
          title  = "Total billing"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              data.aws_instance.main.instance_id
            ]
          ]
          period = 300
          stat   = "Average"
          region = "ap-northeast-1"
          title  = "EC2 Instance CPU"
        }
      },
    ]
  })
}

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