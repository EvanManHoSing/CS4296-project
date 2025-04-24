provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

resource "aws_lambda_function" "huggingface_lambda" {
  function_name = "huggingface-lambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  filename         = "${path.module}/lambda-deploy.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-deploy.zip")

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      HF_API_TOKEN = var.hf_api_token
    }
  }

  snap_start {
    apply_on = "PublishedVersions"
  }
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.huggingface_lambda.function_name
  function_version = aws_lambda_function.huggingface_lambda.version
}

data "aws_caller_identity" "current" {}
