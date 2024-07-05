# Create a custom VPC
resource "aws_vpc" "app_vpc" {    
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "app_vpc"
    }
}

# Create a subnet inside the VPC
resource "aws_subnet" "app_subnet_1" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = "app_subnet"
  }
}

# Create a security group
resource "aws_security_group" "app_sg" {
  name = "app_sg"
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app_sg"
  }
}

# Allow incoming traffic on port 80 for HTTP
resource "aws_security_group_rule" "http_incoming" {
  type        = "ingress"
  from_port   = var.http_port
  to_port     = var.http_port
  protocol    = "tcp"
  cidr_blocks = [var.sg_cidr]
  security_group_id = aws_security_group.app_sg.id
}

# ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "app-cluster"
}

# ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                = "app-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn    = var.execution_role_arn
  cpu                   = "256"
  memory                = "512"

  container_definitions = <<DEFINITION
  [
    {
      "name": "app",
      "image": "nginx",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true
    }
  ]
  DEFINITION
}

# ECS service
resource "aws_ecs_service" "service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.app_subnet_1.id]
    security_groups  = [aws_security_group.app_sg.id]
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket   
 
  tags = {
    Name = "RemoteState"
  }
}

resource "aws_dynamodb_table" "dynamodb_for_state_lock" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}