resource "aws_instance" "instance_dsa" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet

  tags = {
    Name = "Dsa instance output"
  }
}
