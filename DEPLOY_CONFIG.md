# 🚀 Configurações de Deploy AWS EC2 - Dados Gerados

## 📋 Informações da Infraestrutura

**Instância EC2**: i-0dd57f7efc074ef2a
**IP Público**: 18.223.122.46
**DNS**: ec2-18-223-122-46.us-east-2.compute.amazonaws.com
**Região**: us-east-2
**Tipo**: t3.small
**SO**: Ubuntu 24.04

## 🔑 Credenciais Geradas

### SECRET_KEY_BASE
```
4c67e78948970d53dab17f6e2b18f09f9dedf007bfd91eb9ce240eeb944d23df9aa6a9b17eaddcfb0867ca08fa9d925d9051da7fe07c7e953d3ec5ee4b0b2a72
```

### PostgreSQL Password
```
$(openssl rand -base64 32)
```

### DATABASE_URL
```
postgresql://noticed_v2:$(openssl rand -base64 32)@localhost:5432/noticed_v2_production
```

## 📝 Arquivos de Configuração Criados

- `.env.production` - Variáveis de ambiente para produção
- `database.yml.production` - Configuração do banco de dados
- `github_secrets.sh` - Script para configurar secrets no GitHub

## 🚀 Como Configurar

### 1. Configurar Secrets no GitHub
Vá em Settings → Secrets and variables → Actions e adicione:

```bash
AWS_ACCESS_KEY_ID=sua_access_key_aqui
AWS_SECRET_ACCESS_KEY=sua_secret_key_aqui
EC2_SSH_KEY="$(cat couple-synk.pem)"
SECRET_KEY_BASE=4c67e78948970d53dab17f6e2b18f09f9dedf007bfd91eb9ce240eeb944d23df9aa6a9b17eaddcfb0867ca08fa9d925d9051da7fe07c7e953d3ec5ee4b0b2a72
DATABASE_URL=postgresql://noticed_v2:$(openssl rand -base64 32)@localhost:5432/noticed_v2_production
```

### 2. Configurar Servidor EC2
```bash
# Copiar scripts para EC2
scp -i couple-synk.pem scripts/setup_server.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~
scp -i couple-synk.pem scripts/setup_postgresql.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~
scp -i couple-synk.pem scripts/setup_nginx.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~
scp -i couple-synk.pem config/nginx.conf ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:/tmp/

# Conectar e executar
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
chmod +x ~/*.sh
./setup_server.sh
./setup_postgresql.sh
./setup_nginx.sh
```

### 3. Deploy Automático
O deploy será acionado automaticamente quando você fizer push para main/master.

### 4. Deploy Manual
```bash
./scripts/deploy.sh
```

## 📊 Monitoramento
```bash
# Ver logs
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
tail -f /home/ubuntu/apps/noticed_v2/shared/log/puma.stdout.log

# Ver status dos serviços
sudo systemctl status noticed_v2
sudo systemctl status nginx
```

## 🌐 Acesso
**URL**: http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com
**IP**: 18.223.122.46

⚠️ **Importante**: Salve estas informações em um local seguro!