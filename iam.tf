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

resource "aws_ssm_document" "run_shell_deploy_ec2_main" {
  name          = "SSM-RunShell-deploy-to-EC2-main"
  document_type = "Session"
  content = jsonencode({
    schemaVersion = "1.0"
    sessionType   = "Port"
    inputs = {
      runAsEnabled     = true
      runAsDefaultUser = "github_actions_user"
    }
    properties = {
      portNumber = "22"
    }
  })
}

data "aws_iam_policy_document" "ssm_start_and_terminate" {
  statement {
    effect  = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:ap-northeast-1:${data.aws_caller_identity.self.account_id}:instance/${aws_instance.web_server.id}",
      aws_ssm_document.run_shell_deploy_ec2_main.arn,
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:*:session/*"]
  }
}

resource "aws_iam_role_policy" "ssm_start_and_terminate" {
  role   = aws_iam_role.oidc_role_blog_deploy.id
  policy = data.aws_iam_policy_document.ssm_start_and_terminate.json
}