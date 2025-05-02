provider "aws" {
  region = "us-east-2"
}

# Variables for the project
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "dsa-samuel"
}

variable "env" {
  description = "Environment (dev, stage, prod)"
  type        = string
  default     = "dsa-env"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "api_port" {
  description = "Port exposed by the API container"
  type        = number
  default     = 5000
}

variable "frontend_port" {
  description = "Port exposed by the frontend container"
  type        = number
  default     = 80
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "apoena"
}

variable "db_username" {
  description = "RDS username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "RDS password"
  type        = string
  default     = "apoena1212"
  sensitive   = true
}

variable "api_container_image" {
  description = "API Docker image"
  type        = string
  default     = "pentos/todo-api:good"
}

variable "frontend_container_image" {
  description = "Frontend Docker image"
  type        = string
  default     = "pentos/todo-front:good"
}

# VPC and Networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "${var.project_name}-${var.env}-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags         = { Name = "${var.project_name}-${var.env}-private-subnet" }
  public_subnet_tags          = { Name = "${var.project_name}-${var.env}-public-subnet" }
  igw_tags                    = { Name = "${var.project_name}-${var.env}-igw" }
  default_security_group_tags = { Name = "${var.project_name}-${var.env}-default-sg" }
  default_route_table_tags    = { Name = "${var.project_name}-${var.env}-default-rtb" }
  public_route_table_tags     = { Name = "${var.project_name}-${var.env}-public-rtb" }

  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}

# Security Groups
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name   = "${var.project_name}-${var.env}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags = {
    Name = "${var.project_name}-${var.env}-alb-sg"
  }
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name   = "${var.project_name}-${var.env}-ecs-sg"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = var.api_port
      to_port                  = var.api_port
      protocol                 = "tcp"
      description              = "API access from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = var.frontend_port
      to_port                  = var.frontend_port
      protocol                 = "tcp"
      description              = "Frontend access from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_rules = ["all-all"]
  tags = {
    Name = "${var.project_name}-${var.env}-ecs-sg"
  }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name   = "${var.project_name}-${var.env}-db-sg"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from ECS tasks"
      source_security_group_id = module.ecs_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
  tags = {
    Name = "${var.project_name}-${var.env}-db-sg"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.env}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-${var.env}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-${var.env}-db"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t4g.micro" # Smallest RDS instance available
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [module.db_sg.security_group_id]
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-${var.env}-db"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.env}-cluster"
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/${var.project_name}-${var.env}-api"
}

resource "aws_cloudwatch_log_group" "frontend" {
  name = "/ecs/${var.project_name}-${var.env}-frontend"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# SSM Parameters for environment variables
resource "aws_ssm_parameter" "db_url" {
  name  = "/${var.project_name}/${var.env}/DB_URL"
  type  = "SecureString"
  value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
}

resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/${var.project_name}/${var.env}/JWT_SECRET_KEY"
  type  = "SecureString"
  value = "apoena@1212"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.env}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Add SSM parameter read permissions
resource "aws_iam_policy" "ssm_parameter_read" {
  name        = "${var.project_name}-${var.env}-ssm-parameter-read"
  description = "Allow ECS tasks to read SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:us-east-2:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.env}/*"
        ],
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_parameter_read" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ssm_parameter_read.arn
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-${var.env}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.env}-api"
      image     = var.api_container_image
      essential = true
      command   = ["python", "run.py"]

      portMappings = [
        {
          containerPort = var.api_port
          hostPort      = var.api_port
          protocol      = "tcp"
        }
      ],

      secrets = [
        {
          name      = "SQLALCHEMY_DATABASE_URI",
          valueFrom = aws_ssm_parameter.db_url.arn
        },
        {
          name      = "JWT_SECRET_KEY",
          valueFrom = aws_ssm_parameter.jwt_secret.arn
        }
      ],

      environment = [
        {
          name  = "POSTGRES_DB",
          value = var.db_name
        },
        {
          name  = "POSTGRES_USER",
          value = var.db_username
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "ecs"
        }
      },

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.api_port}/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-${var.env}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.env}-frontend"
      image     = var.frontend_container_image
      essential = true

      portMappings = [
        {
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
          protocol      = "tcp"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "${var.project_name}-${var.env}-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "api" {
  name        = "${var.project_name}-${var.env}-api-tg"
  port        = var.api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-${var.env}-frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# ECS Services
resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-${var.env}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [module.ecs_sg.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${var.project_name}-${var.env}-api"
    container_port   = var.api_port
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-${var.env}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [module.ecs_sg.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.project_name}-${var.env}-frontend"
    container_port   = var.frontend_port
  }

  depends_on = [aws_lb_listener.http, aws_ecs_service.api]
}

# Outputs
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The DNS name of the load balancer"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The endpoint of the PostgreSQL RDS instance"
  sensitive   = true
}
