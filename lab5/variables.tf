variable "project_name" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "cpu" {
  type        = string
  description = "CPU type"
}

variable "memory" {
  type        = string
  description = "Memory size"
}

variable "docker_image_name" {
  type        = string
  description = "Docker image name"
}

variable "container_port" {
  type        = number
  description = "Container port"
}

variable "s3_env_vars_file_arn" {
  type        = string
  description = "S3 environment variables file ARN"
}

variable "awslogs_region" {
  type        = string
  description = "AWS logs region"
}

variable "health_check_path" {
  type        = string
  description = "Health check path"
}

variable "health_check_port" {
  type        = number
  description = "Health check port"
}
