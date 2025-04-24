variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
}

variable "hf_api_token" {
  description = "Hugging Face API token"
  type        = string
  sensitive   = true
}

variable "key_name" {
  type        = string
  description = "Name of existing EC2 key pair"
  default     = "vockey"
}

variable "ec2_instance_profile_name" {
  type        = string
  description = "IAM instance profile with ECR pull permissions"
  default     = "LabInstanceProfile"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
  default     = "856563400605" # Replace with your actual AWS account ID
}
