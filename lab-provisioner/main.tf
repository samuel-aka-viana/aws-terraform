resource "aws_instance" "dsa_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "dsa-instance"
  }
  key_name = "chave-ubuntu"

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo bash -c 'echo \"<html><body><h1>Meu primeiro server no ec2 com terraform!</h1></body></html>\" > /var/www/html/index.html'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("chave-ubuntu.pem")
      host        = self.public_ip
    }
  }
}
