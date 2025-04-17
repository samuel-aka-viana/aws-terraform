variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "tags" {
  description = "Tags para o bucket S3"
  type        = map(string)
  default     = {}
}
