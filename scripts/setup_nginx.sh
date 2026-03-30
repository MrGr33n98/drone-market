#!/bin/bash

# Script de configuração do Nginx para Rails
# Executar na instância EC2

set -e

echo "🌐 Configurando Nginx para Rails..."

# Instalar Nginx
sudo apt update
sudo apt install -y nginx

# Criar diretórios necessários
sudo mkdir -p /var/log/nginx
sudo mkdir -p /home/ubuntu/apps/noticed_v2/current/public
sudo mkdir -p /home/ubuntu/apps/noticed_v2/shared/tmp/sockets

# Copiar configuração do Nginx
sudo cp /tmp/nginx.conf /etc/nginx/sites-available/noticed_v2

# Habilitar site
sudo ln -sf /etc/nginx/sites-available/noticed_v2 /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Configurar firewall (se UFW estiver ativado)
if sudo ufw status | grep -q "Status: active"; then
    sudo ufw allow 'Nginx Full'
    sudo ufw allow ssh
fi

echo "✅ Nginx configurado com sucesso!"
echo "🌐 Servidor disponível em: http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com"