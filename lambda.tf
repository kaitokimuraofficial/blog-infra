resource "aws_lambda_function" "zip_lambda_functions" {
  function_name = "zip-lambda-functions"
  role          = aws_iam_role.lambda_blog.arn
  runtime       = "python3.12"
  handler       = "zip_lambda_functions.lambda_handler"

  s3_bucket = aws_s3_bucket.main.bucket
  s3_key    = "lambda_functions/zip_lambda_functions.zip"
}

resource "aws_s3_bucket_notification" "zip_lambda_functions" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.zip_lambda_functions.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "lambda_functions/"
  }
}

resource "aws_lambda_permission" "zip_lambda_functions" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zip_lambda_functions.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main.arn
}

resource "aws_lambda_function" "make_revision" {
  function_name = "make-revisions"
  role          = aws_iam_role.lambda_blog.arn
  runtime       = "python3.12"
  handler       = "make_revision.lambda_handler"

  s3_bucket = aws_s3_bucket.main.bucket
  s3_key    = "lambda_functions/make_revision.zip"
}

resource "aws_s3_bucket_notification" "make_revision" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.make_revision.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "dist/"
  }
}

resource "aws_lambda_permission" "make_revision" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.make_revision.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main.arn
}