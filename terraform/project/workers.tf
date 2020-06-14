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

// boop
resource "aws_api_gateway_rest_api" "dropbox_handler" {
  name        = "neversawus_dropbox_handler"
  description = "Dropbox change event handler - Dispatch to GitHub"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.dropbox_handler.id
  parent_id   = aws_api_gateway_rest_api.dropbox_handler.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.dropbox_handler.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.dropbox_handler.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dropbox_handler.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.dropbox_handler.id
  resource_id   = aws_api_gateway_rest_api.dropbox_handler.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.dropbox_handler.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dropbox_handler.invoke_arn
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

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dropbox_handler.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.dropbox_handler.execution_arn}/*/*"
}

resource "null_resource" "dropbox_handler" {
  provisioner "local-exec" {
    command = "cd files/dropbox_handler && npm ci --only=production"
  }

  triggers = {
    index = base64sha256(file("files/dropbox_handler/lib/index.js"))
  }
}

data "null_data_source" "dropbox_handler" {
  inputs = {
    lambda_exporter_id = null_resource.dropbox_handler.id
    source_dir = "files/dropbox_handler"
  }
}

data "archive_file" "dropbox_handler" {
  output_path = "dist/dropbox_handler.zip"
  source_dir  = data.null_data_source.dropbox_handler.outputs["source_dir"]
  type        = "zip"
}

variable "github_token" {
  type = string
}

resource "aws_lambda_function" "dropbox_handler" {
  role = aws_iam_role.iam_for_lambda.arn
  function_name = "neversawus_dropbox_handler"

  filename         = data.archive_file.dropbox_handler.output_path
  source_code_hash = data.archive_file.dropbox_handler.output_base64sha256

  environment {
    variables = {
      GITHUB_TOKEN = var.github_token
    }
  }

  timeout = 10
  handler = "lib/index.handlers"
  runtime = "nodejs12.x"
}

resource "aws_api_gateway_deployment" "dropbox_handler" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.dropbox_handler.id
  stage_name  = "test"
}

output "base_url" {
  value = aws_api_gateway_deployment.dropbox_handler.invoke_url
}
