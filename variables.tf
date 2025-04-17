variable "region" {
  description = "Região da AWS onde a instância será criada"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}

variable "instance_count" {
  description = "Quantidade de instancias EC2"
  type        = number
}


variable "subnet_id" {
  description = "Subnetes para as instancias EC2 em cada VPC"
  type        = string
}

variable "ami_id" {
  description = "A Amazon Machine Image (AMI) a ser usada pela instancia"
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "tags" {
  description = "Tags para o bucket S3"
  type        = map(string)
  default     = {}
}
