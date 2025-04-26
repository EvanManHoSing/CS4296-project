#!/bin/bash
# Update packages
sudo yum update -y

# Install Docker for Amazon Linux 2023
sudo yum install -y docker

# Start Docker service
sudo service docker start

# Add ec2-user to docker group to run without sudo
sudo usermod -aG docker ec2-user

# Install Docker Compose (latest version)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Fix permissions
sudo chmod +x /usr/local/bin/docker-compose

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 856563400605.dkr.ecr.us-east-1.amazonaws.com

# Pull images
docker pull 856563400605.dkr.ecr.us-east-1.amazonaws.com/my-frontend:latest
docker pull 856563400605.dkr.ecr.us-east-1.amazonaws.com/my-backend:latest

# Create .env file for backend
cat <<EOF > /home/ec2-user/.env
HF_API_TOKEN=${huggingface_api_key}
EOF


# Create docker-compose.yml
cat <<EOF > /home/ec2-user/docker-compose.yml
version: "3.8"
services:
  backend:
    image: 856563400605.dkr.ecr.us-east-1.amazonaws.com/my-backend:latest
    container_name: huggingface-backend
    ports:
      - "5000:5000"
    env_file:
      - .env
    restart: always

  frontend:
    image: 856563400605.dkr.ecr.us-east-1.amazonaws.com/my-frontend:latest
    container_name: huggingface-frontend
    ports:
      - "8501:8501"
    environment:
      - BACKEND_URL=http://backend:5000/generate
    depends_on:
      - backend
    restart: always
EOF

cd /home/ec2-user
docker-compose up -d
