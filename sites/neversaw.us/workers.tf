# this terraform file contains definitions for the content backing the
# blog as well as the dynamic worker scripts and page rules that act
# on that content.

# This bucket contains only static content (HTML & CSS) served in website
# mode.
resource "aws_s3_bucket" "bucket-site" {
  bucket = "www.${var.domain}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "bucket-apocrypha" {
  bucket = "apocrypha.${var.domain}"
  acl    = "private"
}
# - - - - - - cloudflare workers below (postprocessing of markdown file)

# This bucket stores a single, well-known object. The object contains the
# latest build of the cloudflare worker.
resource "aws_s3_bucket" "cloudflare-workers" {
  bucket = "cloudflare-workers"
  acl = "private"
}

# We pull in that well-known object here.
data "aws_s3_bucket_object" "cloudflare_worker_script" {
  bucket = aws_s3_bucket.cloudflare-workers.id
  key    = "neversawus.js"
}

# ...and give it to Cloudflare.
resource "cloudflare_worker_script" "neversawus_worker" {
  zone    = var.domain
  content = data.aws_s3_bucket_object.cloudflare_worker_script.body
}

resource "cloudflare_worker_route" "neversawus_worker_route" {
  zone       = var.domain
  pattern    = "www.${var.domain}/*"
  enabled    = true
  depends_on = [cloudflare_worker_script.neversawus_worker]
}

# - - - - - - aws lambda (take markdown from "raw" and render to "site")

resource "aws_s3_bucket" "bucket-raw" {
  bucket = "raw.${var.domain}"
  acl    = "private"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.renderer.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.bucket-raw.arn
}

resource "aws_lambda_function" "renderer" {
  role = aws_iam_role.iam_for_lambda.arn
  function_name = "neversawus_renderer"
  s3_bucket = aws_s3_bucket.cloudflare-workers.id
  s3_key = "renderer.zip"

  environment {
    variables               = {
      S3_DESTINATION_BUCKET = aws_s3_bucket.bucket-site.id
      S3_ACCESS_KEY         = var.site_access_key # must be provided by environment
      S3_SECRET_KEY         = var.site_secret_key # ditto
    }
  }

  timeout = 10
  handler = "lib/index.handlers"
  runtime = "nodejs10.x"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket-raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.renderer.arn
    events = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

