#!/bin/bash

# Script para configurar secrets no GitHub Actions
# Execute este script para configurar as variáveis de ambiente necessárias

echo "🚀 Configurando secrets para GitHub Actions..."
echo ""

# Gerar SECRET_KEY_BASE
echo "🔑 Gerando SECRET_KEY_BASE..."
SECRET_KEY_BASE=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")

# Ler a chave SSH
echo "📄 Lendo chave SSH..."
if [ -f "couple-synk.pem" ]; then
    SSH_KEY=$(cat couple-synk.pem)
else
    echo "⚠️  Arquivo couple-synk.pem não encontrado!"
    echo "Por favor, certifique-se de que o arquivo está no diretório atual."
    exit 1
fi

echo ""
echo "📋 Secrets a serem configurados no GitHub:"
echo ""
echo "1. AWS_ACCESS_KEY_ID=sua_access_key_aqui"
echo "2. AWS_SECRET_ACCESS_KEY=sua_secret_key_aqui"
echo "3. SECRET_KEY_BASE=$SECRET_KEY_BASE"
echo "4. DATABASE_URL=postgresql://noticed_v2:your_password@localhost:5432/noticed_v2_production"
echo "5. EC2_SSH_KEY=(conteúdo do couple-synk.pem)"
echo ""

# Criar arquivo com as configurações
cat > github_secrets.txt << EOF
# GitHub Actions Secrets Configuration
# Configure estas variáveis em: Settings > Secrets and variables > Actions

AWS_ACCESS_KEY_ID=sua_access_key_aqui
AWS_SECRET_ACCESS_KEY=sua_secret_key_aqui
SECRET_KEY_BASE=$SECRET_KEY_BASE
DATABASE_URL=postgresql://noticed_v2:your_password@localhost:5432/noticed_v2_production
EC2_SSH_KEY="$(echo "$SSH_KEY" | sed 's/"/\\"/g')"
EOF

echo "✅ Arquivo github_secrets.txt criado com as configurações!"
echo ""
echo "📖 Instruções para configurar no GitHub:"
echo "1. Acesse seu repositório no GitHub"
echo "2. Vá para Settings > Secrets and variables > Actions"
echo "3. Clique em 'New repository secret'"
echo "4. Adicione cada uma das variáveis acima"
echo ""
echo "⚠️  Importante:"
echo "- Substitua 'sua_access_key_aqui' e 'sua_secret_key_aqui' pelas suas credenciais AWS"
echo "- Substitua 'your_password' pela senha do PostgreSQL que será gerada"
echo "- Nunca commite o arquivo couple-synk.pem ou github_secrets.txt"
echo ""
echo "🌐 Após configurar os secrets, o deploy automático estará ativado!"

# Opcional: Criar script para aplicar as configurações via GitHub CLI
if command -v gh &> /dev/null; then
    echo ""
    echo "Deseja aplicar as configurações automaticamente via GitHub CLI? (s/n)"
    read -r resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo "Aplicando secrets via GitHub CLI..."
        # Comandos seriam executados aqui se o GH CLI estivesse configurado
        echo "⚠️  Certifique-se de estar autenticado no GitHub CLI antes de continuar"
    fi
fi