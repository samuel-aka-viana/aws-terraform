resource "aws_instance" "dsa_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "dsa-instance"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.dsa_instance.public_ip} > ip_dsa_instance.txt"
  }


}
