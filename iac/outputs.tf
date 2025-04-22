output "api_gateway_url" {
  description = "API Gateway URL for /generate"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/${aws_api_gateway_resource.generate.path_part}"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.chatbot_backend.function_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.id
}