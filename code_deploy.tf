resource "aws_codedeploy_app" "blog" {
  compute_platform = "Server"
  name             = "blog"
}

resource "aws_sns_topic" "blog_codedeploy" {
  name = "blog-codedeploy"
}

resource "aws_codedeploy_deployment_group" "blog" {
  app_name              = aws_codedeploy_app.blog.name
  deployment_group_name = "blog"
  service_role_arn      = aws_iam_role.codedeploy_blog.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "web-server-${local.name_suffix}"
    }
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "blog-trigger"
    trigger_target_arn = aws_sns_topic.blog_codedeploy.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  outdated_instances_strategy = "UPDATE"
}