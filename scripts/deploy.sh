#!/bin/bash

# Script de deploy rápido para EC2
# Executar após configuração inicial

set -e

echo "🚀 Iniciando deploy..."

# Configurações
APP_PATH="/home/ubuntu/apps/noticed_v2"
EC2_HOST="ec2-18-223-122-46.us-east-2.compute.amazonaws.com"
EC2_USER="ubuntu"
SSH_KEY="~/.ssh/couple-synk.pem"

echo "📦 Fazendo deploy para $EC2_HOST..."

# Conectar ao EC2 e executar deploy
ssh -i $SSH_KEY $EC2_USER@$EC2_HOST << 'EOF'
  set -e
  
  echo "📂 Acessando diretório da aplicação..."
  cd /home/ubuntu/apps/noticed_v2
  
  echo "📥 Atualizando código..."
  git pull origin main || git pull origin master
  
  echo "📦 Instalando dependências..."
  bundle config set --local deployment true
  bundle config set --local without development test
  bundle install
  
  echo "🎨 Precompilando assets..."
  RAILS_ENV=production bundle exec rails assets:precompile
  
  echo "🔄 Executando migrações..."
  RAILS_ENV=production bundle exec rails db:migrate
  
  echo "🔄 Reiniciando serviços..."
  sudo systemctl restart noticed_v2
  sudo systemctl restart nginx
  
  echo "✅ Deploy concluído com sucesso!"
EOF

echo "🎉 Deploy finalizado!"
echo "🌐 Acesse: http://$EC2_HOST"