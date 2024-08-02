tflint {
  required_version = ">= 0.50"
}

plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
    enabled = true
    version = "0.9.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule terraform_documented_variables {
  enabled = false
}
