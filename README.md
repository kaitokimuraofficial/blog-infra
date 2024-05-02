# What
Blogのインフラ構成をコード化したもの

# Tips
## Sessionを発行するとき
```md
aws sts get-session-token \
  --serial-number [自分のMFAのarn] \
  --token-code [トークンコード]
```

## backendの設定を隠すために
backend.hclにbackendに関する設定を記述し、
```md
terraform init -backend-config=backend.hcl
```
を実行すると、backendの情報をコードに載せなくてもよくなるので安全。


# Ref
- [AWS Docs](https://docs.aws.amazon.com/ja_jp/)
- [DevelopersIO](https://dev.classmethod.jp/)
- [Terraform Registry](https://registry.terraform.io/namespaces/hashicorp)
