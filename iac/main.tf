provider "aws" {
  region              = "us-east-1"
  access_key          = var.aws_access_key_id
  secret_key          = var.aws_secret_access_key
  token               = var.aws_session_token
}

# VPC
resource "aws_vpc" "chatbot_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "chatbot-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.chatbot_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "chatbot-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.chatbot_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "chatbot-public-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "chatbot_igw" {
  vpc_id = aws_vpc.chatbot_vpc.id
  tags = {
    Name = "chatbot-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.chatbot_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chatbot_igw.id
  }
  tags = {
    Name = "chatbot-public-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.chatbot_vpc.id
  name   = "chatbot-lambda-sg"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "chatbot-lambda-sg"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "cs4296-chatbot-bucket-20250420"
}

# Upload Lambda function code
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "function.zip"
  source = "function.zip"
}

# Secrets Manager for API Token
resource "aws_secretsmanager_secret" "api_token" {
  name = "huggingface-api-token-20250422"
}

resource "aws_secretsmanager_secret_version" "api_token_version" {
  secret_id     = aws_secretsmanager_secret.api_token.id
  secret_string = var.hf_api_token
}

# Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.chatbot_vpc.id
  service_name        = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "chatbot-secretsmanager-endpoint"
  }
}

# Lambda Function
resource "aws_lambda_function" "chatbot_backend" {
  function_name = "ChatbotBackend"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_code.key
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role          = "arn:aws:iam::856563400605:role/LabRole"
  timeout       = 15
  memory_size   = 256
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  depends_on = [aws_vpc_endpoint.secretsmanager]
}

# API Gateway
resource "aws_api_gateway_rest_api" "chatbot_api" {
  name = "ChatbotAPI"
}

resource "aws_api_gateway_resource" "generate" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "generate"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  resource_id   = aws_api_gateway_resource.generate.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.chatbot_api.id
  resource_id             = aws_api_gateway_resource.generate.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.chatbot_backend.invoke_arn
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  depends_on  = [aws_api_gateway_integration.lambda]
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot_backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatbot_api.execution_arn}/*/*"
}