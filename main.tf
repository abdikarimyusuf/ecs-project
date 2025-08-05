provider "aws" {
    region = "eu-west-2"
  
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "public_az1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true 
     availability_zone = "eu-west-2a"
    
  
}

resource "aws_subnet" "public_az2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true 
     availability_zone = "eu-west-2b"
    
  
}

resource "aws_internet_gateway" "internet" {
    vpc_id = aws_vpc.main.id
  
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "security" {
    name = "ecs_sg"
    description = "allow http inbound"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port =5002
        to_port=5002
        protocol ="tcp"
        cidr_blocks = ["0.0.0.0/0"]

    
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}

resource "aws_ecs_cluster" "c" {
    name = "demo-c"
}
  
resource "aws_iam_role" "task-e-r" {
    name = "ecstask-E-R"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
    Action    = "sts:AssumeRole"
    Effect    = "Allow"
    Principal = {
    Service = "ecs-tasks.amazonaws.com"
      }
    }]

    }

    )
  
}

resource "aws_security_group" "alb-sg" {
  name = "alb-sg"
  description = "allow inbound https traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "allow https"
    from_port = 443 #https port
    to_port = 443
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"] 
  }



}

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
data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "ECSrole" 
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








  


