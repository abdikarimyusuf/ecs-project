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