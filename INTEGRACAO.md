# 🚀 Drone Data Platform - Guia de Integração Full-Stack

## 📋 Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    Drone Data Platform                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  FRONTEND (Next.js 15)          BACKEND (Rails 7)           │
│  ┌────────────────────┐         ┌────────────────────┐      │
│  │   App Router       │         │   API REST v1      │      │
│  │   TypeScript       │◄───────►│   ActiveAdmin      │      │
│  │   Tailwind CSS     │  HTTP   │   Noticed v2       │      │
│  │   TanStack Query   │  JSON   │   Devise Auth      │      │
│  └────────────────────┘         └────────────────────┘      │
│         │                              │                     │
│         │                              │                     │
│         ▼                              ▼                     │
│  Port: 3000                      Port: 3001                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Como as Partes se Conectam

### **1. Frontend → Backend**

```typescript
// frontend/src/lib/api.ts
const API_BASE_URL = 'http://localhost:3001/api/v1';

// Exemplo: Buscar pedidos
export const ordersApi = {
  getAll: () => api.get('/orders').then((res) => res.data),
};

// Uso no componente React
const { data: orders } = useQuery({
  queryKey: ['orders'],
  queryFn: ordersApi.getAll,
});
```

### **2. Backend → Frontend**

```ruby
# noticed_v2/app/controllers/api/v1/orders_controller.rb
module Api
  module V1
    class OrdersController < BaseController
      def index
        @orders = Order.all
        render json: @orders  # ← Envia JSON para o frontend
      end
    end
  end
end
```

---

## 📁 Estrutura de Arquivos

### **Backend (Rails)**

```
noticed_v2/
├── app/
│   ├── controllers/
│   │   ├── api/v1/           # API endpoints
│   │   │   ├── orders_controller.rb
│   │   │   ├── missions_controller.rb
│   │   │   └── ...
│   │   └── admin/            # ActiveAdmin
│   ├── models/               # Models Rails
│   │   ├── order.rb
│   │   ├── mission.rb
│   │   └── ...
│   └── admin/                # ActiveAdmin resources
├── db/
│   ├── migrate/              # Migrations
│   └── seeds.rb              # Seeds
└── config/
    └── routes.rb             # Rotas API + Admin
```

### **Frontend (Next.js)**

```
frontend/
├── src/
│   ├── app/                  # Páginas
│   │   ├── dashboard/
│   │   ├── orders/
│   │   └── ...
│   ├── components/           # Componentes React
│   │   ├── ui/               # Componentes base
│   │   └── sidebar.tsx
│   ├── lib/
│   │   ├── api.ts            # API client
│   │   └── utils.ts
│   └── store/
│       └── auth-store.ts     # Zustand
```

---

## 🔄 Fluxo de Dados Completo

### **Exemplo: Criar Novo Pedido**

```
1. Usuário clica em "Novo Pedido" no frontend
   ↓
2. Frontend navega para /orders/new
   ↓
3. Usuário preenche formulário e clica em "Salvar"
   ↓
4. Frontend faz POST para API Rails:
   POST http://localhost:3001/api/v1/orders
   Body: { order: { title: "...", service_type: "..." } }
   ↓
5. Rails OrdersController recebe request
   ↓
6. Model Order valida e salva no banco
   ↓
7. Rails responde com JSON do pedido criado
   ↓
8. Frontend recebe resposta e atualiza cache (React Query)
   ↓
9. Usuário é redirecionado para /orders com lista atualizada
```

---

## 🛠️ Configuração de Ambiente

### **Backend (.env)**

```env
# noticed_v2/.env (se existir)
RAILS_ENV=development
PORT=3001
```

### **Frontend (.env.local)**

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_APP_NAME=Drone Data Platform
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## 🚀 Como Rodar o Projeto

### **1. Iniciar Backend (Rails)**

```bash
cd noticed_v2
rails server -p 3001
# → http://localhost:3001
# → http://localhost:3001/admin
```

### **2. Iniciar Frontend (Next.js)**

```bash
cd frontend
npm run dev
# → http://localhost:3000
```

### **3. Acessar ActiveAdmin**

```
URL: http://localhost:3001/admin
Email: admin@droneplatform.com
Senha: password123
```

---

## 📊 Endpoints da API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/organizations` | Listar organizações |
| GET | `/api/v1/orders` | Listar pedidos |
| POST | `/api/v1/orders` | Criar pedido |
| GET | `/api/v1/missions` | Listar missões |
| GET | `/api/v1/operator_profiles` | Listar operadores |
| GET | `/api/v1/invoices` | Listar faturas |
| GET | `/api/v1/saas_plans` | Listar planos SaaS |
| POST | `/api/v1/saas_leads` | Criar lead |

---

## 🎨 Design System

### **Cores Principais**

```typescript
// Light Theme (Enterprise)
primary: '#0058be'         // Azul corporativo
primaryContainer: '#2170e4'
background: '#f7f9fb'
surface: '#ffffff'

// Dark Theme (High Tech)
primary: '#ffffff'
primaryContainer: '#b9f558'  // Verde neon
background: '#0c141c'
surface: '#141c24'
```

### **Componentes**

```tsx
// Button
<Button variant="primary">Salvar</Button>
<Button variant="accent">Contratar</Button>

// Badge (Status)
<Badge className={getStatusColor(status)}>{status}</Badge>

// Card
<Card>
  <CardHeader><CardTitle>Título</CardTitle></CardHeader>
  <CardContent>Conteúdo...</CardContent>
</Card>
```

---

## 🔐 Autenticação

### **Frontend (Zustand)**

```typescript
// store/auth-store.ts
const { user, isAuthenticated, login, logout } = useAuthStore();

// Login
login(userData, token);

// Logout
logout();
```

### **Backend (Devise)**

```ruby
# Models/User.rb
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable
```

---

## 📝 Próximos Passos

### **Implementar**
- [ ] Páginas de autenticação completas
- [ ] Formulários de criação/edição
- [ ] Upload de arquivos (datasets)
- [ ] Mapa interativo (Leaflet/Mapbox)
- [ ] Gráficos avançados (Recharts)
- [ ] Notificações em tempo real (ActionCable)

### **Otimizar**
- [ ] Lazy loading de imagens
- [ ] Cache estratégico (React Query)
- [ ] SSR/ISR para SEO
- [ ] PWA (offline support)

---

## 🐛 Debug e Troubleshooting

### **Frontend não conecta ao backend**

```bash
# Verificar se backend está rodando
curl http://localhost:3001/api/v1/orders

# Verificar CORS no Rails
# noticed_v2/config/initializers/cors.rb
```

### **Erro de autenticação**

```bash
# Limpar localStorage do navegador
# Verificar token em Application > Local Storage

# Re-fazer login
```

### **Build do frontend falha**

```bash
# Limpar cache
rm -rf .next
npm run build
```

---

## 📚 Recursos Adicionais

- **Docs API:** `docs/api/v1.md`
- **Design System:** `docs/architecture/ui-ux-inspiration/`
- **Frontend README:** `frontend/README.md`
- **Backend README:** `noticed_v2/README.md`

---

**Criado por:** Orion the Orchestrator  
**Data:** 2026-03-29  
**Versão:** 1.0.0
