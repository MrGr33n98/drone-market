#!/bin/bash

# Script de configuração do PostgreSQL para produção
# Executar na instância EC2

set -e

echo "🐘 Configurando PostgreSQL para produção..."

# Instalar PostgreSQL
sudo apt update
sudo apt install -y postgresql postgresql-contrib postgresql-server-dev-all

# Iniciar e habilitar PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Criar usuário e banco de dados
DB_USER="noticed_v2"
DB_NAME="noticed_v2_production"
DB_PASSWORD=$(openssl rand -base64 32)

echo "🔑 Criando usuário e banco de dados..."
sudo -u postgres psql << EOF
-- Criar usuário
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';

-- Criar banco de dados
CREATE DATABASE $DB_NAME OWNER $DB_USER;

-- Conceder privilégios
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Configurar permissões
ALTER USER $DB_USER CREATEDB;
EOF

# Configurar PostgreSQL para aceitar conexões externas
sudo tee /etc/postgresql/*/main/postgresql.conf << EOF
# Configurações de conexão
listen_addresses = '*'
port = 5432
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
wal_buffers = 16MB
checkpoint_completion_target = 0.9
EOF

# Configurar autenticação
sudo tee /etc/postgresql/*/main/pg_hba.conf << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    $DB_NAME       $DB_USER        127.0.0.1/32            md5
EOF

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Criar arquivo de configuração para a aplicação
tee ~/database_config.txt << EOF
# Configurações do Banco de Dados PostgreSQL
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME
DATABASE_USERNAME=$DB_USER
DATABASE_PASSWORD=$DB_PASSWORD
DATABASE_HOST=localhost
DATABASE_PORT=5432
EOF

echo "✅ PostgreSQL configurado com sucesso!"
echo "📋 Configurações salvas em ~/database_config.txt"
echo "🔑 Senha gerada: $DB_PASSWORD"
echo "⚠️  Salve essas informações em um local seguro!"