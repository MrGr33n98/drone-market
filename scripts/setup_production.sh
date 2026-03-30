# Configurações de produção para Noticed V2

# Adicionar ao Gemfile
# gem 'pg'
# gem 'redis'
# gem 'puma'

# 1. Instalar gems de produção
bundle add pg redis puma

# 2. Configurar Puma para produção
tee config/puma_production.rb << 'EOF'
# Puma configuration for production

# Number of worker processes
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Number of threads per worker
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to socket
bind "unix:///home/ubuntu/apps/noticed_v2/shared/tmp/sockets/puma.sock"

# Environment
environment "production"

# PID file
pidfile "/home/ubuntu/apps/noticed_v2/shared/tmp/pids/puma.pid"

# State file
state_path "/home/ubuntu/apps/noticed_v2/shared/tmp/pids/puma.state"

# Preload application
preload_app!

# Worker timeout
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Restart workers periodically
worker_boot_timeout 60
worker_shutdown_timeout 30

# Allow puma to be restarted by `rails restart` command
plugin :tmp_restart

# Logging
stdout_redirect "/home/ubuntu/apps/noticed_v2/shared/log/puma.stdout.log", "/home/ubuntu/apps/noticed_v2/shared/log/puma.stderr.log", true

# Health check
activate_control_app 'unix:///home/ubuntu/apps/noticed_v2/shared/tmp/sockets/pumactl.sock'
EOF

# 3. Criar arquivo de ambiente de produção
tee .env.production << 'EOF'
# Production Environment Variables
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Database
DATABASE_URL=postgresql://noticed_v2:your_secure_password@localhost:5432/noticed_v2_production

# Security
SECRET_KEY_BASE=your_secret_key_here

# Redis (para Action Cable e cache)
REDIS_URL=redis://localhost:6379/0

# Puma
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5

# AWS (se necessário)
AWS_REGION=us-east-2
EOF

# 4. Configurar secrets
tee config/secrets.yml << 'EOF'
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  database_url: <%= ENV["DATABASE_URL"] %>
  redis_url: <%= ENV["REDIS_URL"] %>
EOF

# 5. Atualizar configurações de produção
tee -a config/environments/production.rb << 'EOF'

# Configurações adicionais para EC2
config.force_ssl = false # Desativar SSL por enquanto (pode ativar depois com certificado)
config.ssl = false

# Static files
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

# Logging
config.logger = ActiveSupport::Logger.new(STDOUT)
config.log_level = :info
config.log_tags = [ :request_id ]

# Cache
config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

# Active Job
config.active_job.queue_adapter = :async

# Action Cable
config.action_cable.url = "ws://ec2-18-223-122-46.us-east-2.compute.amazonaws.com/cable"
config.action_cable.allowed_request_origins = [
  "http://ec2-18-223-122-46.us-east-2.compute.amazonaws.com",
  "http://18.223.122.46"
]
EOF

echo "✅ Configurações de produção aplicadas!"
echo "📋 Próximos passos:"
echo "1. Configure as variáveis de ambiente em .env.production"
echo "2. Configure o banco de dados PostgreSQL"
echo "3. Execute: RAILS_ENV=production bundle exec rails assets:precompile"
echo "4. Execute: RAILS_ENV=production bundle exec rails db:migrate"