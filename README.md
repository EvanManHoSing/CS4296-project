# CS4296-project
Research on both serverless (AWS Fargate + Lambda) and hypervisor-based (AWS EC2 with Docker) approaches are viable, with trade-offs in cost and scalability.

## Step to deploy on AWS
0. Make sure you have install Docker, AWS CLI and Terraform
1. configure AWS CLI
```
aws configure
```

```
aws configure set aws_session_token <your-session-token>
```

2. Docker Build and push to AWS ECR
```
# Navigate to backend directory
cd backend
docker build -t my-backend .

# Navigate to frontend directory
cd ../frontend
docker build -t my-frontend .
```

Authenticate Docker to ECR
```
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

Create ECR Repositories
```
aws ecr create-repository --repository-name my-backend
aws ecr create-repository --repository-name my-frontend
```

Tag and Push
```
# Tag
docker tag my-backend <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-backend
docker tag my-frontend <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-frontend

# Push
docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-backend
docker push <your-account-id>.dkr.ecr.<region>.amazonaws.com/my-frontend
```




## Step for test locally
0. ~~Create token.txt in backend/ then paste the API token~~
use environment variable now.
```
export HF_API_TOKEN="your HF_API_TOKEN"
```
or
```
$env:HF_API_TOKEN = "your HF_API_TOKEN"
```

1. create virtual environment
```
python -m venv .venv
```
  or
```
python3 -m venv .venv
```
2. activate venv
```
source .venv/bin/activate
```
  or
```
.\.venv\Scripts\Activate.ps1
```
3. install requirement
```
pip install -r requirements.txt
```

4. run frontend and backend
```
python backend/backend.py
```
```
streamlit run frontend.py
```
## backend test command
```
curl -X POST -H "Content-Type: application/json" -d '{"prompt": "Hello, how are you?"}' http://localhost:5000/generate
```
