provider "aws" {
  region = "us-west-2"
}

# Define the ECR repository for frontend
resource "aws_ecr_repository" "frontend" {
  name = "frontend-repo"
}
# Define the ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
}

# Define the ECS Task Definition for frontend
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend-task"
  container_definitions    = jsonencode([{
    name      = "frontend"
    image     = aws_ecr_repository.frontend.repository_url
    cpu       = 256
    memory    = 512
    essential = true
  }])
  cpu =256
  memory =512

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
}

# Define the ECS Service for frontend
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

#Network configuration for fargate
network_configuration {
  subnets  =["subnet-040901a45b97241eb", "subnet-0ef4c157450f6db33"]
  security_groups=["sg-068176616a0407c15"]
  assign_public_ip = true
 }
}

# Define IAM roles for execution and task roles (simplified for this example)
resource "aws_iam_role" "execution_role" {
  name = "ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}
resource "aws_iam_role" "task_role" {
  name = "ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
