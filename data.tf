# Get the Route 53 zone for your domain
data "aws_route53_zone" "main" {
  name         = "abdikarim.co.uk"
  private_zone = false
}


data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "ECSrole" 
}