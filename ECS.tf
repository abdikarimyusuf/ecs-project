resource "aws_lb" "ecs-lb" {
  name = "ecs-lb"
  internal = false # public
  load_balancer_type ="application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = [aws_subnet.public_az1.id,aws_subnet.public_az2.id]
  
}

resource "aws_lb_target_group" "ecs-tg" {

  name = "ecs-tg"
  port = 5002
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"

    health_check {
    path                = "/"
    port                = "5002"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

   
}



resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.task-e-r.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets_policy" {
  role       = aws_iam_role.task-e-r.name
  policy_arn = aws_iam_policy.ecs_secrets_access.arn
}

resource "aws_iam_policy" "ecs_secrets_access" {
  name        = "ecs-task-secrets-access"
  description = "Allows ECS task to get secret from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:eu-west-2:533567531054:secret:secret_docker-P8kAtn"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "ecs_demo_task" {
  name = "/ecs/demo-task"
  retention_in_days = 1
}
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








  


