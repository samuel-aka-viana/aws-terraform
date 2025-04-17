variable "region" {
  description = "Região da AWS onde a instância será criada"
  type        = string
  default     = "us-east-2"
}

variable "instance_count" {
  description = "Número de instâncias EC2 a serem criadas"
  type        = number
  default     = 2

}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}


variable "subnet" {
  description = "Subnetes para as instancias EC2 em cada VPC"
  type        = string
}

variable "ami_id" {
  description = "A Amazon Machine Image (AMI) a ser usada pela instancia"
  type        = string
}
