resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "ecs-fargate-dashboard"

  dashboard_body = jsonencode({
    "widgets" : [
      # ECS Metrics
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "fargate-cluster", "ServiceName", "my-fargate-service"]
          ],
          "title" : "ECS CPU Utilization",
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", "fargate-cluster", "ServiceName", "my-fargate-service"]
          ],
          "title" : "ECS Memory Utilization",
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1"
        }
      },


      # EC2 Metrics
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.app_server.id}"]
          ],
          "title" : "EC2 CPU Utilization",
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkIn", "InstanceId", "${aws_instance.app_server.id}"],
            ["AWS/EC2", "NetworkOut", "InstanceId", "${aws_instance.app_server.id}"]
          ],
          "title" : "EC2 Network Traffic",
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1"
        }
      },

      # Lambda Metrics
      {
        "type" : "metric",
        "x" : 0,
        "y" : 24,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.huggingface_lambda.function_name}"]
          ],
          "title" : "Lambda Invocations",
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 24,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.huggingface_lambda.function_name}"]
          ],
          "title" : "Lambda Duration",
          "period" : 300,
          "stat" : "Average",
          "region" : "us-east-1"
        }
      },

      # Lambda Network Metrics
      {
        "type" : "metric",
        "x" : 0,
        "y" : 36,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "NetworkIn", "FunctionName", "${aws_lambda_function.huggingface_lambda.function_name}"]
          ],
          "title" : "Lambda Network In",
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 36,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/Lambda", "NetworkOut", "FunctionName", "${aws_lambda_function.huggingface_lambda.function_name}"]
          ],
          "title" : "Lambda Network Out",
          "period" : 300,
          "stat" : "Sum",
          "region" : "us-east-1"
        }
      }
    ]
  })
}
