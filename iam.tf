resource "aws_ssm_document" "github_actions" {
  name          = "SSM-SessionManagerRunShell-Deploy"
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

##############################################################
# IAM
##############################################################
data "aws_iam_policy_document" "github_actions_assume_role_policy" {
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

resource "aws_iam_role" "oidc_role" {
  name               = "oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect  = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:ap-northeast-1:${data.aws_caller_identity.self.account_id}:instance/${aws_instance.frontend.id}",
      aws_ssm_document.github_actions.arn,
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:*:session/*"]
  }
}

resource "aws_iam_role_policy" "role_policy" {
  role   = aws_iam_role.oidc_role.id
  policy = data.aws_iam_policy_document.policy_document.json
}
