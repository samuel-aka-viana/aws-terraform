variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Environment (dev, stage, prod)"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azail_zone_1" {
  description = "Availability Zone 1"
  type        = string
}

variable "azail_zone_2" {
  description = "Availability Zone 2"
  type        = string
}

variable "public_subnet_1_cidr_block" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr_block" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr_block" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = string
}

variable "alb_sg_port" {
  description = "Port for ALB security group"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
}

variable "memory" {
  description = "Memory for the task in MB"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name with web application"
  type        = string
}

variable "s3_env_vars_file_arn" {
  description = "S3 ARN for environment variables file"
  type        = string
}

variable "awslogs_region" {
  description = "AWS region for logs"
  type        = string
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}
