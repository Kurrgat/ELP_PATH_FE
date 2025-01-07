# Output the ECR Repository URI for the frontend
output "frontend_repo_uri" {
  description = "URI of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

# Output the ECS Cluster Name
output "ecs_cluster_name" {
  description = "The ECS Cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

# Output the ECS Service Name
output "ecs_service_name" {
  description = "The ECS Service name"
  value       = aws_ecs_service.frontend_service.name
}

# Output the ECS Task Definition ARN
output "ecs_task_definition" {
  description = "The ECS Task Definition ARN"
  value       = aws_ecs_task_definition.frontend_task_definition.arn
}
