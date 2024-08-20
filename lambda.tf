data "archive_file" "zip_lambda_functions" {
  type        = "zip"
  source_file = "lambda_functions/zip_lambda_functions.py"
  output_path = "lambda_functions/zip_lambda_functions.zip"
}

resource "aws_lambda_function" "zip_lambda_functions" {
  function_name = "zip-lambda-functions"
  role          = aws_iam_role.lambda_blog.arn
  runtime       = "python3.12"
  handler       = "zip_lambda_functions.lambda_handler"

  filename         = data.archive_file.zip_lambda_functions.output_path
  source_code_hash = data.archive_file.zip_lambda_functions.output_base64sha256
}

resource "aws_lambda_permission" "zip_lambda_functions" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zip_lambda_functions.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main.arn
}

data "archive_file" "make_revision" {
  type        = "zip"
  source_file = "lambda_functions/make_revision.py"
  output_path = "lambda_functions/make_revision.zip"
}

resource "aws_lambda_function" "make_revision" {
  function_name = "make-revisions"
  role          = aws_iam_role.lambda_blog.arn
  runtime       = "python3.12"
  handler       = "make_revision.lambda_handler"

  filename         = data.archive_file.make_revision.output_path
  source_code_hash = data.archive_file.make_revision.output_base64sha256
}

resource "aws_lambda_permission" "make_revision" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.make_revision.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main.arn
}

resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.make_revision.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "revision/appspec.yml"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.make_revision.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "revision/dist/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.zip_lambda_functions.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "lambda_functions/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.make_revision.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "revision/scripts/"
  }
}