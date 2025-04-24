resource "aws_ecs_cluster" "main" {
  name = "fargate-cluster"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "856563400605.dkr.ecr.us-east-1.amazonaws.com/frontend:latest"
      essential = true
      portMappings = [{
        containerPort = 8501
        hostPort      = 8501
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "BACKEND_URL"
          value = "https://di5zl9r1i3.execute-api.us-east-1.amazonaws.com/prod/generate"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "my-fargate-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = ["sg-0297051b09c90f56b"]
    assign_public_ip = true
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
