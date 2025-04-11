# CS4296-project
Research on both serverless (AWS Fargate + Lambda) and hypervisor-based (AWS EC2 with Docker) approaches are viable, with trade-offs in cost and scalability.

## TODO
1. Install log and metric to the app
2. Containerize frontend
3. Migrate to AWS



## backend test command
```
curl -X POST -H "Content-Type: application/json" -d '{"prompt": "Hello, how are you?"}' http://localhost:5000/generate
```

## Step
0. Put token.txt into key/
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
