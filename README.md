# CS4296-project
Research on both serverless (AWS Fargate + Lambda) and hypervisor-based (AWS EC2 with Docker) approaches are viable, with trade-offs in cost and scalability.





## backend test command
```
curl -X POST -H "Content-Type: application/json" -d '{"prompt": "Hello, how are you?"}' http://localhost:5000/generate
```