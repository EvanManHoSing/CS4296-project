resource "aws_instance" "app_server" {
  ami                         = "ami-0e449927258d45bc4" # Amazon Linux 2023 AMI
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  vpc_security_group_ids      = ["sg-0297051b09c90f56b"]
  associate_public_ip_address = true
  iam_instance_profile        = var.ec2_instance_profile_name

  user_data = templatefile("${path.module}/scripts/ec2-user-data.sh", {
    huggingface_api_key = var.hf_api_token
  })

  tags = {
    Name = "HuggingFaceEC24"
  }
}
