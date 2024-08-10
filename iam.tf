data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "gha_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.self.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:kaitokimuraofficial/blog:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "oidc_role_blog_deploy" {
  name               = "oidc-role-blog-deploy"
  assume_role_policy = data.aws_iam_policy_document.gha_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_mic" {
  role       = aws_iam_role.ec2_session_s3_logging_role.name
  policy_arn = data.aws_iam_policy.amazon_ssm_managed_instance_core.arn
}

data "aws_iam_policy" "amazon_ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_full_access" {
  role       = aws_iam_role.ec2_session_s3_logging_role.name
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
}

data "aws_iam_policy" "amazon_s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "ssm_send_command" {
  role   = aws_iam_role.oidc_role_blog_deploy.id
  policy = data.aws_iam_policy_document.ssm_send_command.json
}

data "aws_iam_policy_document" "ssm_send_command" {
  statement {
    effect  = "Allow"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.self.account_id}:instance/${aws_instance.web_server.id}",
      "arn:aws:ssm:*:*:document/AWS-RunShellScript",
    ]
  }
}

resource "aws_iam_role" "codedeploy_blog" {
  name               = "codedeploy-blog"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "aws_codedeploy_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy_blog.name
}