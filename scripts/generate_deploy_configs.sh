#!/bin/bash

# Script completo para preparar o deploy
# Execute este script para gerar todas as configurações necessárias

echo "🚀 Preparando configurações para deploy AWS EC2..."
echo ""

# Criar diretório de configurações
mkdir -p config/deploy
echo "📁 Diretório config/deploy criado"

# Gerar SECRET_KEY_BASE
echo "🔑 Gerando SECRET_KEY_BASE..."
SECRET_KEY_BASE=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")

# Verificar se a chave SSH existe
if [ -f "couple-synk.pem" ]; then
    echo "✅ Chave SSH couple-synk.pem encontrada"
    SSH_KEY_CONTENT=$(cat couple-synk.pem)
else
    echo "⚠️  Arquivo couple-synk.pem não encontrado!"
    echo "Por favor, coloque o arquivo couple-synk.pem no diretório raiz do projeto."
    exit 1
fi

# Gerar senha segura para PostgreSQL
POSTGRES_PASSWORD=$(openssl rand -base64 32)

echo "📝 Criando arquivos de configuração..."

# Criar arquivo de variáveis de ambiente para produção
cat > config/deploy/.env.production << EOF
# Production Environment Variables
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Database
DATABASE_URL=postgresql://noticed_v2:${POSTGRES_PASSWORD}@localhost:5432/noticed_v2_production

# Security
SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Redis (para Action Cable e cache)
REDIS_URL=redis://localhost:6379/0

# Puma
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5

# AWS
AWS_REGION=us-east-2
EOF

# Criar arquivo de configuração do banco de dados para produção
cat > config/deploy/database.yml.production << EOF
# PostgreSQL. Versions 9.3 and up are supported.
production:
  adapter: postgresql
  encoding: unicode
  database: noticed_v2_production
  username: noticed_v2
  password: ${POSTGRES_PASSWORD}
  host: localhost
  port: 5432
  url: postgresql://noticed_v2:${POSTGRES_PASSWORD}@localhost:5432/noticed_v2_production
  prepared_statements: false
  connect_timeout: 5
  checkout_timeout: 5
  reaping_frequency: 10
  dead_connection_timeout: 30
EOF

# Criar arquivo de secrets para GitHub Actions
cat > config/deploy/github_secrets.sh << 'EOF'
#!/bin/bash

# GitHub Actions Secrets Configuration
# Execute os comandos abaixo no seu terminal para configurar os secrets

echo "Configurando secrets no GitHub..."

# Configurar AWS credenciais (substitua pelos seus valores)
echo "gh secret set AWS_ACCESS_KEY_ID --body 'sua_access_key_aqui'"
echo "gh secret set AWS_SECRET_ACCESS_KEY --body 'sua_secret_key_aqui'"

# Configurar SECRET_KEY_BASE
echo "gh secret set SECRET_KEY_BASE --body '${SECRET_KEY_BASE}'"

# Configurar DATABASE_URL
echo "gh secret set DATABASE_URL --body 'postgresql://noticed_v2:${POSTGRES_PASSWORD}@localhost:5432/noticed_v2_production'"

# Configurar EC2_SSH_KEY
echo "gh secret set EC2_SSH_KEY --body '$(cat couple-synk.pem | sed 's/"/\\"/g')'"

echo ""
echo "📋 Comandos para configurar os secrets manualmente:"
echo "1. Acesse seu repositório no GitHub"
echo "2. Vá para Settings > Secrets and variables > Actions"
echo "3. Clique em 'New repository secret' para cada uma:"
echo ""
echo "AWS_ACCESS_KEY_ID=sua_access_key_aqui"
echo "AWS_SECRET_ACCESS_KEY=sua_secret_key_aqui"
echo "SECRET_KEY_BASE=${SECRET_KEY_BASE}"
echo "DATABASE_URL=postgresql://noticed_v2:${POSTGRES_PASSWORD}@localhost:5432/noticed_v2_production"
echo "EC2_SSH_KEY=(conteúdo completo do arquivo couple-synk.pem)"
EOF

# Criar arquivo de instruções
cat > config/deploy/README.md << EOF
# 🚀 Configurações de Deploy AWS EC2

## 📋 Informações da Infraestrutura

**Instância EC2**: i-0dd57f7efc074ef2a
**IP Público**: 18.223.122.46
**DNS**: ec2-18-223-122-46.us-east-2.compute.amazonaws.com
**Região**: us-east-2
**Tipo**: t3.small
**SO**: Ubuntu 24.04

## 🔑 Credenciais Geradas

### SECRET_KEY_BASE
\`\`\`
${SECRET_KEY_BASE}
\`\`\`

### PostgreSQL Password
\`\`\`
${POSTGRES_PASSWORD}
\`\`\`

### DATABASE_URL
\`\`\`
postgresql://noticed_v2:${POSTGRES_PASSWORD}@localhost:5432/noticed_v2_production
\`\`\`

## 📝 Arquivos de Configuração

- \`.env.production\` - Variáveis de ambiente para produção
- \`database.yml.production\` - Configuração do banco de dados
- \`github_secrets.sh\` - Script para configurar secrets no GitHub

## 🚀 Como Configurar

### 1. Configurar Secrets no GitHub
Execute o script \`github_secrets.sh\` ou configure manualmente:

1. Acesse seu repositório no GitHub
2. Vá para Settings > Secrets and variables > Actions
3. Adicione os seguintes secrets:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - SECRET_KEY_BASE
   - DATABASE_URL
   - EC2_SSH_KEY

### 2. Configurar Servidor EC2
Conecte-se à instância e execute os scripts de configuração.

### 3. Deploy Automático
O deploy será acionado automaticamente quando você fizer push para main/master.

## 🔧 Comandos Úteis

\`\`\`bash
# Conectar ao servidor
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com

# Ver logs da aplicação
tail -f /home/ubuntu/apps/noticed_v2/shared/log/puma.stdout.log

# Reiniciar serviços
sudo systemctl restart noticed_v2
sudo systemctl restart nginx
\`\`\`

## 📞 Suporte

Para problemas com o deploy, verifique:
1. Logs da aplicação
2. Status dos serviços (systemctl status)
3. Configurações de ambiente
4. Secrets do GitHub Actions
EOF

echo ""
echo "✅ Configurações criadas com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "  - config/deploy/.env.production"
echo "  - config/deploy/database.yml.production"
echo "  - config/deploy/github_secrets.sh"
echo "  - config/deploy/README.md"
echo ""
echo "📝 Próximos passos:"
echo "1. Configure os secrets no GitHub Actions usando o script github_secrets.sh"
echo "2. Conecte-se ao EC2 e execute os scripts de configuração"
echo "3. Faça push para main/master para ativar o deploy automático"
echo ""
echo "🔗 Aplicação estará disponível em: http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com"
echo ""
echo "⚠️  Importante: Salve estas informações em um local seguro!"

# Tornar o script executável
chmod +x config/deploy/github_secrets.sh

echo ""
echo "💡 Dica: Execute 'config/deploy/github_secrets.sh' para ver os comandos de configuração"