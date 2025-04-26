# CS4296 Project - Serverless vs Hypervisor-based Deployment

This project researches and compares two cloud deployment architectures for a web-based LLM chatbot:

- **Serverless architecture** using AWS Fargate and Lambda
- **Hypervisor-based architecture** using AWS EC2 and Docker

Both approaches have trade-offs in terms of **cost**, **scalability**, and **performance**.

---

## Deployment Guide on AWS

### Prerequisites
- [Docker](https://docs.docker.com/get-started/get-docker/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Make sure Docker, AWS CLI, and Terraform are installed and properly configured.

---

### Step 1: Configure AWS CLI
```
aws configure
aws configure set aws_session_token <your-session-token>
```

### Step 2: Configure Terraform
Create your own terraform.tfvars file under the iac/ directory.

You can use terraform.tfvars.example as a template.

### Step 3: Docker Build and Push to AWS ECR
Build Docker Images
```
# Backend
cd hypervisor-based/backend
docker build -t my-backend .

# Frontend
cd ../frontend
docker build -t my-frontend .
```

Authenticate Docker to AWS ECR
```
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

Create ECR Repositories
```
aws ecr create-repository --repository-name my-backend
aws ecr create-repository --repository-name my-frontend
```

Tag and Push Images
```
docker tag my-backend <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-backend
docker tag my-frontend <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-frontend

docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-backend
docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-frontend
```

Step 4: Deploy Using Terraform
```
cd ../../iac
terraform init
terraform plan
terraform apply
```

---
## Testing Locally
### Step 0: Set Hugging Face API Token
Linux / macOS:
```
export HF_API_TOKEN="your HF_API_TOKEN"
```
Windows (PowerShell):
```
$env:HF_API_TOKEN = "your HF_API_TOKEN"
```

### Step 1: Create Virtual Environment
```
python -m venv .venv
# or
python3 -m venv .venv
```

### Step 2: Activate Virtual Environment
Linux / macOS:
```
source .venv/bin/activate
```

Windows (PowerShell):
```
.\.venv\Scripts\Activate.ps1
```

### Step 3: Install Requirements
```
pip install -r requirements.txt
```

### Step 4: Run Frontend and Backend
```
# Backend
python hypervisor-based/backend/backend.py

# Frontend
streamlit run hypervisor-based/frontend/frontend.py
```

### Local Backend Test Command
```
curl -X POST -H "Content-Type: application/json" -d '{"prompt": "Hello, how are you?"}' http://localhost:5000/generate
```

