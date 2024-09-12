data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_functions/${var.source_file}"
  output_path = "lambda_functions/${var.output_zip}"
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = var.role_arn
  runtime       = var.runtime
  handler       = var.handler

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_permission" "lambda" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}