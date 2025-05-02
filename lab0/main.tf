#tfsec:ignore:AVD-AWS-0028   # IMDSv2 opcional
#tfsec:ignore:AVD-AWS-0131   # volume raiz sem criptografia
resource "aws_instance" "dsa_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "dsa-instance"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip_dsa_instance.txt"
  }
}
