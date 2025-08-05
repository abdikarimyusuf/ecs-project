
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.c.name
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}