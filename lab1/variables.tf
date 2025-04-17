variable "region" {
  description = "Região da AWS onde a instância será criada"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}

variable "vpc_ids" {
  description = "IDs das VPCs onde a instância EC2 será criada"
  type        = list(string)
}

variable "subnets" {
  description = "Subnetes para as instancias EC2 em cada VPC"
  type        = list(string)
}

variable "ami_id" {
  description = "A Amazon Machine Image (AMI) a ser usada pela instancia"
  type        = string
}
