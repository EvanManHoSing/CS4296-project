provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}

data "aws_caller_identity" "current" {}

# Lambda Function
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

# Lambda Alias for live version
resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.huggingface_lambda.function_name
  function_version = aws_lambda_function.huggingface_lambda.version
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "chat_api" {
  name          = "ChatAPI"
  protocol_type = "HTTP"
}

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.chat_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.huggingface_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway Route for Lambda function
resource "aws_apigatewayv2_route" "chat_route" {
  api_id    = aws_apigatewayv2_api.chat_api.id
  route_key = "POST /generate"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Stage (production)
resource "aws_apigatewayv2_stage" "chat_stage" {
  api_id      = aws_apigatewayv2_api.chat_api.id
  name        = "prod"
  auto_deploy = true
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.huggingface_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.chat_api.execution_arn}/*/*"
}

# Outputs API Gateway URL
data "aws_region" "current" {}

output "api_gateway_url" {
  value = "https://${aws_apigatewayv2_api.chat_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod/generate"
}
