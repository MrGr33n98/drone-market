#!/bin/bash

# Script de configuração do servidor EC2 para Rails
# Executar como usuário ubuntu

set -e

echo "🚀 Iniciando configuração do servidor Rails..."

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências essenciais
sudo apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev \
    libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libpq-dev nginx \
    postgresql postgresql-contrib redis-server nodejs npm yarn

# Instalar Ruby com rbenv
cd ~
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Instalar ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Recarregar bashrc
source ~/.bashrc

# Instalar Ruby 3.2.2
rbenv install 3.2.2
rbenv global 3.2.2

# Instalar Bundler
gem install bundler

# Configurar PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Criar usuário e banco de dados
sudo -u postgres psql << EOF
CREATE USER noticed_v2 WITH PASSWORD 'your_secure_password';
CREATE DATABASE noticed_v2_production OWNER noticed_v2;
GRANT ALL PRIVILEGES ON DATABASE noticed_v2_production TO noticed_v2;
EOF

# Configurar Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Criar diretório da aplicação
mkdir -p ~/apps/noticed_v2
cd ~/apps/noticed_v2

# Clonar repositório (será atualizado pelo deploy)
git clone https://github.com/your-username/your-repo.git .

# Instalar dependências do Ruby
bundle config set --local deployment true
bundle config set --local without development test
bundle install

# Criar secrets
SECRET_KEY_BASE=$(bundle exec rails secret)
echo "SECRET_KEY_BASE=${SECRET_KEY_BASE}" >> ~/.bashrc

# Configurar Nginx
sudo tee /etc/nginx/sites-available/noticed_v2 << 'EOF'
server {
    listen 80;
    server_name ec2-18-223-122-46.us-east-2.compute.amazonaws.com;
    
    root /home/ubuntu/apps/noticed_v2/public;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /assets {
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip_static on;
    }
    
    location /cable {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Habilitar site no Nginx
sudo ln -sf /etc/nginx/sites-available/noticed_v2 /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Testar e reiniciar Nginx
sudo nginx -t
sudo systemctl restart nginx

# Criar serviço SystemD para a aplicação
sudo tee /etc/systemd/system/noticed_v2.service << 'EOF'
[Unit]
Description=Noticed V2 Rails Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/apps/noticed_v2
Environment=RAILS_ENV=production
Environment=SECRET_KEY_BASE=${SECRET_KEY_BASE}
Environment=DATABASE_URL=postgresql://noticed_v2:your_secure_password@localhost/noticed_v2_production
ExecStart=/home/ubuntu/.rbenv/shims/bundle exec rails server -p 3000 -b 0.0.0.0
ExecReload=/bin/kill -USR1 $MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recarregar SystemD e habilitar serviço
sudo systemctl daemon-reload
sudo systemctl enable noticed_v2

# Criar script de deploy
tee ~/deploy.sh << 'EOF'
#!/bin/bash
set -e

cd ~/apps/noticed_v2

# Pull latest code
git pull origin main || git pull origin master

# Install dependencies
bundle config set --local deployment true
bundle config set --local without development test
bundle install

# Precompile assets
RAILS_ENV=production bundle exec rails assets:precompile

# Run migrations
RAILS_ENV=production bundle exec rails db:migrate

# Restart services
sudo systemctl restart noticed_v2
sudo systemctl restart nginx

echo "✅ Deploy completed successfully!"
EOF

chmod +x ~/deploy.sh

echo "🎉 Configuração do servidor concluída!"
echo "📋 Próximos passos:"
echo "1. Configure as secrets no GitHub Actions"
echo "2. Configure o banco de dados em config/database.yml"
echo "3. Teste o deploy com: ./deploy.sh"
echo "4. Acesse: http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com"