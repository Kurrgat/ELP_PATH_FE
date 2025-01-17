 provider "aws" {
  region = "us-east-2"
}

# ECR Repository
resource "aws_ecr_repository" "frontend" {
  name = "frontend-repo"
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
}

# IAM Roles
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

# ECS Task Definition
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend-task"
  container_definitions    = jsonencode([{
    name      = "backend"
    image     = aws_ecr_repository.frontend.repository_url
    cpu       = 256
    memory    = 512
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/frontend-task"
        awslogs-region        = "us-east-2" # Replace with your AWS region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
}

# Optional: CloudWatch log group creation
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/frontend-task"
  retention_in_days = 30 # Adjust retention as needed
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  vpc_id      = "vpc-06322973708b9d9c9" # Replace with your actual VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Service
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0b265d00ac0a11eb6"] # Replace with your actual Subnet IDs
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
