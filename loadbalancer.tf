
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
