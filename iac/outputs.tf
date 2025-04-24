# Outputs API Gateway URL
output "api_gateway_url" {
  value = "https://${aws_apigatewayv2_api.chat_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod/generate"
}

output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP of the EC2 instance"
}
