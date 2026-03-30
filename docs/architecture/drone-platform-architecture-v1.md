# Drone Data Platform — Arquitetura Técnica v1

## Visão Geral

**Stack:** Rails 7 + ActiveAdmin 3.2 + Noticed v2 + Devise  
**Backend:** `noticed_v2/` (porta 3001)  
**Banco:** SQLite (dev) → PostgreSQL (prod)

---

## 1. Estrutura de Diretórios

```
noticed_v2/
├── app/
│   ├── models/
│   │   ├── concerns/
│   │   │   ├── has_compliance.rb
│   │   │   ├── has_audit_logs.rb
│   │   │   └── has_webhooks.rb
│   │   ├── identity/
│   │   │   ├── organization.rb
│   │   │   └── membership.rb
│   │   ├── saas/
│   │   │   ├── saas_plan.rb
│   │   │   ├── saas_subscription.rb
│   │   │   └── saas_lead.rb
│   │   ├── marketplace/
│   │   │   ├── operator_profile.rb
│   │   │   ├── order.rb
│   │   │   ├── bid.rb
│   │   │   └── mission.rb
│   │   ├── equipment/
│   │   │   ├── equipment.rb
│   │   │   ├── sensor_type.rb
│   │   │   └── operator_equipment.rb
│   │   ├── data/
│   │   │   ├── dataset.rb
│   │   │   └── qa_review.rb
│   │   ├── finance/
│   │   │   ├── invoice.rb
│   │   │   ├── payment.rb
│   │   │   └── payout.rb
│   │   ├── compliance/
│   │   │   └── compliance_document.rb
│   │   ├── communication/
│   │   │   ├── conversation.rb
│   │   │   └── message.rb
│   │   └── core/
│   │       ├── audit_log.rb
│   │       └── webhook.rb
│   ├── admin/
│   │   ├── organizations_admin.rb
│   │   ├── orders_admin.rb
│   │   ├── missions_admin.rb
│   │   ├── operators_admin.rb
│   │   ├── finance_admin.rb
│   │   └── saas_admin.rb
│   └── controllers/
│       └── api/
│           └── v1/ (futuro)
├── db/
│   ├── migrate/
│   └── seeds/
│       ├── development.rb
│       └── production.rb
└── config/
    ├── initializers/
    │   └── active_admin.rb
    └── routes.rb
```

---

## 2. Migrations (Ordem de Execução)

### **Identity Module**

```ruby
# db/migrate/20260329000001_create_organizations.rb
class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :cnpj
      t.string :status, default: 'active'
      t.text :settings, default: {}
      t.timestamps
    end
    add_index :organizations, :cnpj, unique: true
  end
end

# db/migrate/20260329000002_create_memberships.rb
class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :role, default: 'member' # admin, member, viewer
      t.string :status, default: 'active' # invited, active, revoked
      t.timestamps
    end
    add_index :memberships, [:user_id, :organization_id], unique: true
  end
end

# db/migrate/20260329000003_add_organization_to_users.rb
class AddOrganizationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :organization, foreign_key: true
  end
end
```

### **SaaS Module**

```ruby
# db/migrate/20260329000010_create_saas_plans.rb
class CreateSaasPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :saas_plans do |t|
      t.string :name, null: false
      t.string :slug, null: false, unique: true
      t.decimal :price_cents, precision: 10, scale: 0
      t.string :billing_cycle, default: 'monthly' # monthly, yearly
      t.string :status, default: 'active'
      t.jsonb :features, default: []
      t.timestamps
    end
  end
end

# db/migrate/20260329000011_create_saas_subscriptions.rb
class CreateSaasSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :saas_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :saas_plan, null: false, foreign_key: true
      t.string :status, default: 'trialing' # trialing, active, past_due, cancelled, expired
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.timestamps
    end
  end
end

# db/migrate/20260329000012_create_saas_leads.rb
class CreateSaasLeads < ActiveRecord::Migration[7.0]
  def change
    create_table :saas_leads do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :company
      t.string :phone
      t.string :source # website, referral, ads, event
      t.string :status, default: 'new' # new, contacted, qualified, lost, converted
      t.text :notes
      t.timestamps
    end
  end
end
```

### **Marketplace Module**

```ruby
# db/migrate/20260329000020_create_operator_profiles.rb
class CreateOperatorProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :operator_profiles do |t|
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.string :status, default: 'pending' # pending, verified, suspended, blocked
      t.string :company_name
      t.string :cnpj
      t.text :bio
      t.string :phone
      t.string :city
      t.string :state
      t.float :rating_avg, default: 0.0
      t.integer :rating_count, default: 0
      t.integer :missions_completed, default: 0
      t.jsonb :service_areas, default: [] # [{city, state, radius_km}]
      t.timestamps
    end
  end
end

# db/migrate/20260329000021_create_orders.rb
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :service_type, null: false # inspection, mapping, survey, monitoring
      t.string :status, default: 'draft' # draft, open, in_progress, completed, cancelled
      t.text :description
      t.datetime :scheduled_start
      t.datetime :scheduled_end
      t.decimal :budget_cents, precision: 10, scale: 0
      t.jsonb :requirements, default: {}
      t.timestamps
    end
  end
end

# db/migrate/20260329000022_create_bids.rb
class CreateBids < ActiveRecord::Migration[7.0]
  def change
    create_table :bids do |t|
      t.references :order, null: false, foreign_key: true
      t.references :operator_profile, null: false, foreign_key: true
      t.decimal :amount_cents, precision: 10, scale: 0, null: false
      t.integer :delivery_days, null: false
      t.text :proposal
      t.string :status, default: 'pending' # pending, accepted, rejected, withdrawn
      t.timestamps
    end
    add_index :bids, [:order_id, :operator_profile_id], unique: true
  end
end

# db/migrate/20260329000023_create_missions.rb
class CreateMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :missions do |t|
      t.references :order, null: false, foreign_key: true
      t.references :operator_profile, null: false, foreign_key: true
      t.references :bid, null: false, foreign_key: true
      t.string :code, null: false, unique: true # MISSION-YYYY-XXXX
      t.string :status, default: 'pending' # pending, scheduled, in_progress, completed, cancelled
      t.datetime :scheduled_start
      t.datetime :scheduled_end
      t.datetime :actual_start
      t.datetime :actual_end
      t.jsonb :flight_plan, default: {}
      t.timestamps
    end
  end
end
```

### **Equipment Module**

```ruby
# db/migrate/20260329000030_create_sensor_types.rb
class CreateSensorTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :sensor_types do |t|
      t.string :name, null: false # RGB, Multispectral, Thermal, LiDAR
      t.string :category, null: false # camera, lidar, multispectral, thermal
      t.text :description
      t.timestamps
    end
  end
end

# db/migrate/20260329000031_create_equipments.rb
class CreateEquipments < ActiveRecord::Migration[7.0]
  def change
    create_table :equipments do |t|
      t.string :name, null: false # DJI Mavic 3E, Phantom 4 RTK
      t.string :manufacturer, null: false
      t.references :sensor_type, foreign_key: true
      t.jsonb :specifications, default: {}
      t.timestamps
    end
  end
end

# db/migrate/20260329000032_create_operator_equipments.rb
class CreateOperatorEquipments < ActiveRecord::Migration[7.0]
  def change
    create_table :operator_equipments do |t|
      t.references :operator_profile, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.string :serial_number
      t.boolean :available, default: true
      t.timestamps
    end
    add_index :operator_equipments, [:operator_profile_id, :equipment_id], unique: true
  end
end
```

### **Data & QA Module**

```ruby
# db/migrate/20260329000040_create_datasets.rb
class CreateDatasets < ActiveRecord::Migration[7.0]
  def change
    create_table :datasets do |t|
      t.references :mission, null: false, foreign_key: true
      t.string :name, null: false
      t.string :type, null: false # orthomosaic, point_cloud, ndvi, thermal
      t.string :status, default: 'processing' # processing, ready, delivered
      t.string :storage_path
      t.decimal :size_mb, precision: 10, scale: 2
      t.jsonb :metadata, default: {} # gsd, area_km2, points_count
      t.datetime :delivered_at
      t.timestamps
    end
  end
end

# db/migrate/20260329000041_create_qa_reviews.rb
class CreateQaReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :qa_reviews do |t|
      t.references :mission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # reviewer
      t.string :status, default: 'pending' # pending, approved, rejected, revision_requested
      t.integer :gsd_check, default: 0 # 0-5
      t.integer :coverage_check, default: 0 # 0-5
      t.integer :quality_check, default: 0 # 0-5
      t.text :comments
      t.jsonb :checklist, default: {}
      t.timestamps
    end
  end
end
```

### **Finance Module**

```ruby
# db/migrate/20260329000050_create_invoices.rb
class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.references :mission, foreign_key: true
      t.string :invoice_number, null: false, unique: true
      t.decimal :subtotal_cents, precision: 10, scale: 0, null: false
      t.decimal :tax_cents, precision: 10, scale: 0, default: 0
      t.decimal :discount_cents, precision: 10, scale: 0, default: 0
      t.decimal :total_cents, precision: 10, scale: 0, null: false
      t.string :status, default: 'pending' # pending, paid, overdue, cancelled
      t.datetime :due_date
      t.timestamps
    end
  end
end

# db/migrate/20260329000051_create_payments.rb
class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount_cents, precision: 10, scale: 0, null: false
      t.string :provider, null: false # stripe, pagseguro, manual
      t.string :status, default: 'pending' # pending, completed, failed, refunded
      t.string :transaction_id
      t.jsonb :metadata, default: {}
      t.datetime :paid_at
      t.timestamps
    end
  end
end

# db/migrate/20260329000052_create_payouts.rb
class CreatePayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :payouts do |t|
      t.references :mission, null: false, foreign_key: true
      t.references :operator_profile, null: false, foreign_key: true
      t.decimal :gross_amount_cents, precision: 10, scale: 0, null: false
      t.decimal :platform_fee_cents, precision: 10, scale: 0, null: false
      t.decimal :net_amount_cents, precision: 10, scale: 0, null: false
      t.string :status, default: 'pending' # pending, processing, paid, cancelled
      t.string :payment_method # pix, bank_transfer
      t.jsonb :bank_details, default: {}
      t.datetime :paid_at
      t.timestamps
    end
  end
end
```

### **Compliance Module**

```ruby
# db/migrate/20260329000060_create_compliance_documents.rb
class CreateComplianceDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :compliance_documents do |t|
      t.references :operator_profile, null: false, foreign_key: true
      t.string :document_type, null: false # anac, cac, insurance, cnh
      t.string :file_path, null: false
      t.string :file_checksum
      t.datetime :issue_date
      t.datetime :expiry_date
      t.string :status, default: 'pending' # pending, valid, expired, rejected
      t.text :rejection_reason
      t.timestamps
    end
    add_index :compliance_documents, :expiry_date
  end
end
```

### **Communication Module**

```ruby
# db/migrate/20260329000070_create_conversations.rb
class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :order, foreign_key: true
      t.references :mission, foreign_key: true
      t.string :subject
      t.timestamps
    end
    add_index :conversations, [:order_id, :mission_id]
  end
end

# db/migrate/20260329000071_create_messages.rb
class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.string :attachment_path
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
```

### **Core Module**

```ruby
# db/migrate/20260329000080_create_audit_logs.rb
class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.jsonb :changes, default: {}
      t.string :request_id
      t.string :ip_address
      t.timestamps
    end
    add_index :audit_logs, [:auditable_type, :auditable_id]
  end
end

# db/migrate/20260329000081_create_webhooks.rb
class CreateWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :webhooks do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :url, null: false
      t.string :secret, null: false
      t.jsonb :events, default: [] # order.created, mission.completed, etc.
      t.string :status, default: 'active'
      t.timestamps
    end
  end
end
```

---

## 3. Models (Associations)

### **Identity**

```ruby
# app/models/organization.rb
class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  
  has_many :orders
  has_many :operator_profiles
  has_many :invoices
  has_many :webhooks
  
  validates :name, presence: true
  validates :cnpj, uniqueness: true, allow_nil: true
end

# app/models/membership.rb
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  
  validates :role, inclusion: { in: %w[admin member viewer] }
  validates :status, inclusion: { in: %w[invited active revoked] }
  validates :user_id, uniqueness: { scope: :organization_id }
end
```

### **Marketplace**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  
  has_many :bids, dependent: :destroy
  has_one :mission, dependent: :nullify
  has_many :conversations, dependent: :destroy
  
  validates :title, presence: true
  validates :service_type, presence: true
  validates :status, inclusion: { 
    in: %w[draft open in_progress completed cancelled] 
  }
end

# app/models/mission.rb
class Mission < ApplicationRecord
  belongs_to :order
  belongs_to :operator_profile
  belongs_to :bid
  
  has_many :datasets, dependent: :destroy
  has_one :qa_review, dependent: :destroy
  has_one :payout, dependent: :destroy
  
  validates :code, presence: true, uniqueness: true
  
  before_create :generate_code
  
  private
  
  def generate_code
    year = Time.current.year
    sequence = Mission.where("EXTRACT(year FROM created_at) = ?", year).count + 1
    self.code = format("MISSION-%d-%04d", year, sequence)
  end
end
```

### **Finance**

```ruby
# app/models/invoice.rb
class Invoice < ApplicationRecord
  belongs_to :organization
  belongs_to :order, optional: true
  belongs_to :mission, optional: true
  has_many :payments, dependent: :destroy
  
  validates :invoice_number, presence: true, uniqueness: true
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }
  
  before_save :calculate_total
  
  private
  
  def calculate_total
    self.total_cents = subtotal_cents + tax_cents - discount_cents
  end
end

# app/models/payout.rb
class Payout < ApplicationRecord
  belongs_to :mission
  belongs_to :operator_profile
  
  validates :gross_amount_cents, numericality: { greater_than: 0 }
  validates :platform_fee_cents, numericality: { greater_than_or_equal_to: 0 }
  
  before_save :calculate_net
  
  private
  
  def calculate_net
    self.net_amount_cents = gross_amount_cents - platform_fee_cents
  end
end
```

---

## 4. ActiveAdmin Resources

### **Dashboard Configuration**

```ruby
# app/admin/dashboard.rb
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "dashboard_wrapper" do
      # Stats
      panels do
        panel "Pedidos Ativos" do
          Order.where(status: 'open').count
        end
        panel "Missões em Andamento" do
          Mission.where(status: 'in_progress').count
        end
        panel "Operadores Verificados" do
          OperatorProfile.where(status: 'verified').count
        end
        panel "Faturas Pendentes" do
          Invoice.where(status: 'pending').count
        end
      end
      
      # Recent Orders
      table_for Order.order(created_at: :desc).limit(10) do
        column :title
        column :organization
        column :status
        column :created_at
        column "" do |order|
          link_to "Ver", admin_order_path(order)
        end
      end
    end
  end
end
```

### **Order Admin**

```ruby
# app/admin/orders.rb
ActiveAdmin.register Order do
  permit_params :organization_id, :user_id, :title, :service_type, 
                :status, :description, :scheduled_start, :scheduled_end, 
                :budget_cents, requirements: {}

  index do
    selectable_column
    column :title
    column :organization
    column :user
    column :service_type
    column :status do |order|
      span order.status, class: order.status
    end
    column :bids_count do |order|
      order.bids.count
    end
    column :created_at
    actions
  end

  filter :title
  filter :service_type
  filter :status
  filter :organization

  show do
    attributes_table do
      row :title
      row :description
      row :service_type
      row :status
      row :organization
      row :user
      row :budget_cents
      row :scheduled_start
      row :scheduled_end
      row :requirements
      row :created_at
      row :updated_at
    end
    
    panel "Propostas" do
      table_for order.bids do
        column :operator_profile
        column :amount_cents
        column :delivery_days
        column :status
        column :created_at
      end
    end
    
    panel "Missão" do
      if order.mission
        attributes_table_for order.mission do
          row :code
          row :status
          row :operator_profile
          row :scheduled_start
          row :scheduled_end
        end
      else
        span "Nenhuma missão criada"
      end
    end
  end
end
```

### **Mission Admin**

```ruby
# app/admin/missions.rb
ActiveAdmin.register Mission do
  permit_params :order_id, :operator_profile_id, :bid_id, :status,
                :scheduled_start, :scheduled_end, :actual_start, :actual_end,
                flight_plan: {}

  index do
    selectable_column
    column :code
    column :order
    column :operator_profile
    column :status
    column :scheduled_start
    column :scheduled_end
    column :datasets_count do |mission|
      mission.datasets.count
    end
    actions
  end

  filter :code
  filter :status
  filter :operator_profile

  show do
    attributes_table do
      row :code
      row :order
      row :bid
      row :operator_profile
      row :status
      row :scheduled_start
      row :scheduled_end
      row :actual_start
      row :actual_end
      row :flight_plan
    end
    
    panel "Datasets" do
      table_for mission.datasets do
        column :name
        column :type
        column :status
        column :size_mb
        column :created_at
      end
    end
    
    panel "QA Review" do
      if mission.qa_review
        attributes_table_for mission.qa_review do
          row :status
          row :reviewer
          row :gsd_check
          row :coverage_check
          row :quality_check
          row :comments
        end
      else
        span "QA não realizado"
      end
    end
  end
  
  action_item :review_qa, only: :show do
    if mission.status == 'completed' && !mission.qa_review
      link_to "Realizar QA", new_admin_qa_review_path(mission_id: mission.id)
    end
  end
end
```

### **Finance Admin**

```ruby
# app/admin/invoices.rb
ActiveAdmin.register Invoice do
  permit_params :organization_id, :order_id, :mission_id, 
                :subtotal_cents, :tax_cents, :discount_cents, 
                :status, :due_date

  index do
    selectable_column
    column :invoice_number
    column :organization
    column :order
    column :total_cents
    column :status
    column :due_date
    column :paid_at
    actions
  end

  filter :invoice_number
  filter :organization
  filter :status
  filter :due_date

  show do
    attributes_table do
      row :invoice_number
      row :organization
      row :order
      row :mission
      row :subtotal_cents
      row :tax_cents
      row :discount_cents
      row :total_cents
      row :status
      row :due_date
      row :payments
    end
  end
end

ActiveAdmin.register Payout do
  permit_params :mission_id, :operator_profile_id, 
                :gross_amount_cents, :platform_fee_cents,
                :status, :payment_method, bank_details: {}

  index do
    selectable_column
    column :mission
    column :operator_profile
    column :gross_amount_cents
    column :platform_fee_cents
    column :net_amount_cents
    column :status
    column :paid_at
    actions
  end
end
```

### **Operator Admin**

```ruby
# app/admin/operator_profiles.rb
ActiveAdmin.register OperatorProfile do
  permit_params :user_id, :organization_id, :status, :company_name,
                :cnpj, :bio, :phone, :city, :state, 
                service_areas: {}

  index do
    selectable_column
    column :user
    column :company_name
    column :city
    column :state
    column :status
    column :rating_avg
    column :missions_completed
    actions
  end

  filter :user
  filter :status
  filter :city
  filter :state

  show do
    attributes_table do
      row :user
      row :organization
      row :company_name
      row :cnpj
      row :status
      row :phone
      row :city
      row :state
      row :rating_avg
      row :rating_count
      row :missions_completed
      row :service_areas
      row :created_at
    end
    
    panel "Equipamentos" do
      table_for operator_profile.operator_equipments do
        column :equipment
        column :serial_number
        column :available
      end
    end
    
    panel "Documentos" do
      table_for operator_profile.compliance_documents do
        column :document_type
        column :status
        column :expiry_date
      end
    end
  end
  
  action_item :verify, only: :show do
    if operator_profile.status == 'pending'
      link_to "Verificar", verify_admin_operator_profile_path(operator_profile), method: :patch
    end
  end
end
```

---

## 5. Seeds (Dados de Exemplo)

```ruby
# db/seeds/development.rb

# Identity
org = Organization.create!(
  name: "Energy Corp",
  cnpj: "00.000.000/0001-00"
)

admin_user = User.create!(
  email: "admin@energy.com",
  password: "password123",
  password_confirmation: "password123",
  organization: org
)

# SaaS
plan = SaasPlan.create!(
  name: "Enterprise",
  slug: "enterprise",
  price_cents: 99900,
  billing_cycle: "monthly",
  features: ["unlimited_orders", "api_access", "priority_support"]
)

# Operator
operator_user = User.create!(
  email: "pilot@drone.com",
  password: "password123"
)

operator = OperatorProfile.create!(
  user: operator_user,
  company_name: "Drone Solutions",
  cnpj: "11.111.111/0001-11",
  city: "São Paulo",
  state: "SP",
  status: "verified",
  rating_avg: 4.8,
  missions_completed: 42
)

# Equipment
sensor = SensorType.create!(
  name: "RGB",
  category: "camera"
)

equipment = Equipment.create!(
  name: "DJI Mavic 3E",
  manufacturer: "DJI",
  sensor_type: sensor
)

OperatorEquipment.create!(
  operator_profile: operator,
  equipment: equipment,
  serial_number: "DJ123456"
)

# Order
order = Order.create!(
  organization: org,
  user: admin_user,
  title: "Inspeção de Linhas de Transmissão",
  service_type: "inspection",
  status: "open",
  description: "Inspeção de 50km de linhas de transmissão",
  budget_cents: 5000000
)

# Bid
bid = Bid.create!(
  order: order,
  operator_profile: operator,
  amount_cents: 4500000,
  delivery_days: 5,
  proposal: "Realizaremos a inspeção em 5 dias úteis",
  status: "pending"
)

puts "✅ Seeds criados com sucesso!"
puts "   Admin: admin@energy.com / password123"
puts "   Operator: pilot@drone.com / password123"
```

---

## 6. Rotas (config/routes.rb)

```ruby
Rails.application.routes.draw do
  # ActiveAdmin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Devise (users)
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # API (futuro)
  namespace :api do
    namespace :v1 do
      resources :orders, only: [:index, :show, :create]
      resources :bids, only: [:index, :show, :create]
      resources :missions, only: [:index, :show]
      resources :datasets, only: [:index, :show]
    end
  end
  
  # Web
  resources :users do
    get :profile, on: :collection
  end
  
  resources :posts do
    resources :comments
  end
  
  get 'home', to: 'pages#home'
  get 'about', to: 'pages#about'
  
  root 'pages#home'
end
```

---

## 7. Próximos Passos

### **Fase 2: Migrations** 💻
```bash
cd noticed_v2
rails generate migration CreateOrganizations
# (copiar conteúdo da arquitetura)
rails db:migrate
```

### **Fase 3: Models** 🧱
```bash
# Criar models com associations
rails generate model Organization name:string cnpj:string
# (copiar conteúdo da arquitetura)
```

### **Fase 4: ActiveAdmin** 🎛️
```bash
# Criar recursos admin
rails generate active_admin:resource Organization
# (copiar conteúdo da arquitetura)
```

### **Fase 5: Seeds** 🌱
```bash
rails db:seed:replant
```

---

## 8. Checklist de Validação

- [ ] Migrations criadas e executadas
- [ ] Models com associations testadas
- [ ] ActiveAdmin resources acessíveis
- [ ] Seeds rodando sem erros
- [ ] Dashboard do ActiveAdmin mostrando stats
- [ ] CRUD de Orders funcional
- [ ] CRUD de Missions funcional
- [ ] Finance (Invoices/Payouts) funcional

---

**Documento criado por:** @architect (Aria)  
**Data:** 2026-03-29  
**Versão:** 1.0  
**PRD Referência:** Drone Data Platform v2
