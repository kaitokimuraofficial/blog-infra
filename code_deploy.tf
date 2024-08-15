resource "aws_codedeploy_app" "blog" {
  compute_platform = "Server"
  name             = "blog"
}

resource "aws_codedeploy_deployment_group" "blog" {
  app_name               = aws_codedeploy_app.blog.name
  deployment_group_name  = "blog"
  service_role_arn       = aws_iam_role.codedeploy_blog.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "web-server-${local.name_suffix}"
    }
  }

  outdated_instances_strategy = "UPDATE"
}