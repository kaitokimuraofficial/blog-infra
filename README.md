# Blog-infra

- Website: http://www.kaitokimura.com
- Documentation: [Blog-infra Documentations](main/docs/)

This repository is infra code storage for [kaitokimuraofficial/blog](https://github.com/kaitokimuraofficial/blog/).

If you want to check my website, jump to [kaitokimura.com](http://www.kaitokimura.com)!
If you have some questions, please ask me in [discussions](https://github.com/kaitokimuraofficial/blog-infra/discussions/)!

## Architecture

The diagram of the architecture actually built in this repository is stored in [images](/images).
If you want to see how the architecture has evolved to its current state, please take a look.

The current architecture is as follows.
| `current architecture` |
| -- |
| ![current architecture](/images/0.1.1.png) |

## For Developing

This repository uses Terraform. So, when developing this repository codes, documentations and websites below helps us a lot.

- To learn more about Terraform itself, refer to [Terraform](https://developer.hashicorp.com/terraform)

- To learn more about Terraform style conventions, refer to [Style Guide](https://developer.hashicorp.com/terraform/language/style)

- To acquire Terraform comprehensive knowledge, read [Terraform: Up and Running](https://www.oreilly.com/library/view/terraform-up-and/9781098116736/)


Following repositories are used in this codes
| Name | URL | Simple description |
| -- | -- | -- |
| `aws-vault`| [aws-vault](https://github.com/99designs/aws-vault) | a tool to securely store and access AWS credentials in a dev environment |
| `tflint`| [tflint](https://github.com/terraform-linters/tflint) | A Plugin Terraform Linter |
