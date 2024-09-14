module "make_revision" {
  source        = "./modules/lambda_function"
  function_name = "make-revisions"
  role_arn      = aws_iam_role.lambda_blog.arn
  handler       = "make_revision.lambda_handler"
  source_file   = "make_revision.py"
  output_zip    = "make_revision.zip"
  bucket_arn    = aws_s3_bucket.main.arn
}

module "zip_lambda_functions" {
  source        = "./modules/lambda_function"
  function_name = "zip-lambda-functions"
  role_arn      = aws_iam_role.lambda_blog.arn
  handler       = "zip_lambda_functions.lambda_handler"
  source_file   = "zip_lambda_functions.py"
  output_zip    = "zip_lambda_functions.zip"
  bucket_arn    = aws_s3_bucket.main.arn
}

resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  lambda_function {
    lambda_function_arn = module.make_revision.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "revision/"
  }

  lambda_function {
    lambda_function_arn = module.zip_lambda_functions.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "lambda_functions/"
  }
}