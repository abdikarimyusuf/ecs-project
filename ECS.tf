
resource "aws_ecs_task_definition" "tas" {
  family                   = "demo-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = aws_iam_role.task-e-r.arn
container_definitions = jsonencode([
  {
    name      = "demo-container"
    image     = "abdikarim98/my-name:myimage3",
    repositoryCredentials: {
      "credentialsParameter": "arn:aws:secretsmanager:eu-west-2:533567531054:secret:secret_docker-P8kAtn"
    }

    portMappings = [
      {
        containerPort = 5002
        hostPort      = 5002
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/demo-task"                 # You can name this anything
        awslogs-region        = "eu-west-2"                      # Your region
        awslogs-stream-prefix = "ecs"                            # Just a prefix for grouping logs
      }
    }
  }
])

}

resource "aws_ecs_service" "demo" {
    name = "demo-s"
    cluster = aws_ecs_cluster.c.id
    task_definition = aws_ecs_task_definition.tas.arn  #Amazon Resource Name A full, globally unique identifier.,arn:aws:ecs:us-east-1:123456789012:task-definition/my-task:1
    desired_count = 1
    launch_type = "FARGATE"
    network_configuration {
      subnets = [aws_subnet.public_az1.id,aws_subnet.public_az2.id]
      security_groups = [aws_security_group.security.id]
      assign_public_ip = true
    }

    load_balancer {
  target_group_arn = aws_lb_target_group.ecs-tg.arn
  container_name   = "demo-container"
  container_port   = 5002
}
  
}








  


