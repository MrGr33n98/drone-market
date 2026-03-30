# 🚀 Pipeline de Deploy AWS EC2

Este guia explica como configurar a pipeline de deploy automático para AWS EC2.

## 📋 Pré-requisitos

- Conta AWS com permissões EC2
- Repositório no GitHub
- Ruby 3.2.2 e Rails 7.0.6
- Acesso SSH à instância EC2

## 🔧 Configuração Inicial

### 1. Configurar Secrets no GitHub

Vá para Settings → Secrets and variables → Actions e adicione:

```bash
AWS_ACCESS_KEY_ID=seu_access_key
AWS_SECRET_ACCESS_KEY=seu_secret_key
EC2_SSH_KEY="$(cat couple-synk.pem)"
SECRET_KEY_BASE=$(rails secret)
DATABASE_URL=postgresql://user:pass@localhost:5432/noticed_v2_production
```

### 2. Configurar Instância EC2

Conecte-se à sua instância:
```bash
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
```

Execute o script de configuração:
```bash
# Copie os scripts para a instância
scp -i couple-synk.pem scripts/setup_server.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~

# Conecte e execute
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
chmod +x setup_server.sh
./setup_server.sh
```

### 3. Configurar PostgreSQL
```bash
# Copie o script de configuração do PostgreSQL
scp -i couple-synk.pem scripts/setup_postgresql.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~

# Execute na instância
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
./setup_postgresql.sh
```

### 4. Configurar Nginx
```bash
# Copie a configuração do Nginx
scp -i couple-synk.pem config/nginx.conf ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:/tmp/

# Copie e execute o script de configuração do Nginx
scp -i couple-synk.pem scripts/setup_nginx.sh ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com:~
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com
./setup_nginx.sh
```

## 🔄 Deploy Automático

### Via GitHub Actions
O deploy automático é acionado quando você faz push para as branches `main` ou `master`.

### Deploy Manual
Se precisar fazer deploy manualmente:
```bash
# Execute o script de deploy
./scripts/deploy.sh
```

## 📊 Monitoramento

### Verificar status dos serviços
```bash
ssh -i couple-synk.pem ubuntu@ec2-18-223-122-46.us-east-2.compute.amazonaws.com

# Status da aplicação
sudo systemctl status noticed_v2

# Status do Nginx
sudo systemctl status nginx

# Status do PostgreSQL
sudo systemctl status postgresql

# Status do Redis
sudo systemctl status redis-server
```

### Logs
```bash
# Logs da aplicação
tail -f /home/ubuntu/apps/noticed_v2/shared/log/puma.stdout.log
tail -f /home/ubuntu/apps/noticed_v2/shared/log/puma.stderr.log

# Logs do Nginx
sudo tail -f /var/log/nginx/noticed_v2_access.log
sudo tail -f /var/log/nginx/noticed_v2_error.log

# Logs do sistema
sudo journalctl -u noticed_v2 -f
```

## 🔧 Manutenção

### Reiniciar serviços
```bash
# Reiniciar aplicação
sudo systemctl restart noticed_v2

# Reiniciar Nginx
sudo systemctl restart nginx

# Reiniciar PostgreSQL
sudo systemctl restart postgresql
```

### Backup do banco de dados
```bash
# Criar backup
pg_dump -U noticed_v2 noticed_v2_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
psql -U noticed_v2 noticed_v2_production < backup.sql
```

## 🚨 Troubleshooting

### Aplicação não inicia
```bash
# Verificar logs
tail -f /home/ubuntu/apps/noticed_v2/shared/log/puma.stderr.log

# Verificar permissões
sudo chown -R ubuntu:ubuntu /home/ubuntu/apps/noticed_v2/

# Verificar configurações
RAILS_ENV=production bundle exec rails console
```

### Nginx erro 502
```bash
# Verificar se Puma está rodando
sudo systemctl status noticed_v2

# Verificar socket
ls -la /home/ubuntu/apps/noticed_v2/shared/tmp/sockets/

# Testar configuração do Nginx
sudo nginx -t
```

### Problemas de conexão
```bash
# Verificar firewall
sudo ufw status

# Verificar portas
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :3000

# Verificar DNS
dig ec2-18-223-122-46.us-east-2.compute.amazonaws.com
```

## 📈 Performance

### Otimizações recomendadas:
1. **Adicionar CDN** para assets estáticos
2. **Configurar SSL/TLS** com Let's Encrypt
3. **Adicionar monitoramento** com CloudWatch
4. **Configurar cache** com Redis
5. **Otimizar queries** do banco de dados

## 🔐 Segurança

### Configurações de segurança:
1. **Mudar portas padrão** (SSH, PostgreSQL)
2. **Configurar firewall** (UFW)
3. **Atualizar regularmente** pacotes do sistema
4. **Configurar fail2ban** para proteção contra ataques
5. **Habilitar SSL** para tráfego criptografado

## 📞 Suporte

Para problemas com o deploy:
1. Verifique os logs da aplicação
2. Confira as configurações de ambiente
3. Teste a conectividade com a instância
4. Verifique os secrets do GitHub Actions

---

**URL da Aplicação**: http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com
**IP Público**: 18.223.122.46
**Região AWS**: us-east-2