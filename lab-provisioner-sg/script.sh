#!/bin/bash
set -e

# Atualiza os pacotes e instala o Apache (httpd)
sudo yum update -y
sudo yum install httpd -y

# Inicia o serviço do Apache
sudo systemctl start httpd

# Cria a página index.html com o conteúdo da landing page
sudo bash -c "cat > /var/www/html/index.html << 'EOF'

