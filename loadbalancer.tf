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
