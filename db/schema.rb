# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_26_150038) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "additional_fees", force: :cascade do |t|
    t.decimal "additional_fee"
    t.integer "additional_type"
    t.integer "additional_model"
    t.string "condition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "name_profile", default: 0
  end

  create_table "archives", force: :cascade do |t|
    t.string "file"
    t.string "archiveable_type", null: false
    t.bigint "archiveable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["archiveable_type", "archiveable_id"], name: "index_archives_on_archiveable"
    t.index ["user_id"], name: "index_archives_on_user_id"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id", null: false
    t.integer "status"
    t.string "email"
    t.string "phone_number"
    t.string "street"
    t.string "commune"
    t.string "address_number"
    t.string "responsible_name"
    t.string "latitude"
    t.string "longitude"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region"
    t.string "reference"
    t.string "dpto"
    t.string "address_concat"
    t.time "time_open"
    t.time "time_close"
    t.integer "default_price"
    t.boolean "invert", default: false
    t.index ["company_id"], name: "index_branches_on_company_id"
  end

  create_table "commune_prices", force: :cascade do |t|
    t.string "commune"
    t.decimal "price"
    t.string "region_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "name_profile", default: 0
  end

  create_table "companies", force: :cascade do |t|
    t.string "rut"
    t.string "name"
    t.string "address_number"
    t.string "street"
    t.string "commune"
    t.string "email"
    t.string "phone_number"
    t.string "web_address"
    t.integer "status"
    t.string "fantasy_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number_address"
    t.string "postal_code"
    t.string "region"
    t.string "dpto"
    t.string "address_concat"
    t.string "latitude"
    t.string "longitude"
    t.string "responsible_name"
    t.string "reference"
    t.time "time_open"
    t.time "time_close"
    t.boolean "require_api", default: false
    t.boolean "accepted_api", default: false
    t.string "secret_key"
    t.boolean "automatic_payment", default: true
    t.boolean "shipping_without_payment", default: false
    t.boolean "requires_additional_fee", default: true
    t.integer "name_profile", default: 0
    t.integer "client_type_payment"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "deals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.integer "total_amount", default: 0
    t.integer "status_deal", default: 0
    t.integer "utility"
    t.integer "total_cost"
    t.decimal "descount"
    t.bigint "user_id"
    t.integer "iva"
    t.integer "price_with_iva"
    t.boolean "only_save", default: false
    t.string "reason_rejected"
    t.string "pay_description"
    t.decimal "additional_amount", default: "0.0"
    t.jsonb "additional_details", default: {}
    t.index ["company_id"], name: "index_deals_on_company_id"
    t.index ["user_id"], name: "index_deals_on_user_id"
  end

  create_table "default_profile_prices", force: :cascade do |t|
    t.integer "price", null: false
    t.integer "name_profile", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_profile"], name: "index_default_profile_prices_on_name_profile", unique: true
  end

  create_table "deliveries", force: :cascade do |t|
    t.string "weight"
    t.string "height"
    t.string "width"
    t.string "depth"
    t.datetime "date_start", precision: nil
    t.datetime "date_end", precision: nil
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "branch_id", null: false
    t.string "address_street"
    t.string "address_number"
    t.string "region"
    t.string "commune"
    t.string "reference"
    t.string "city"
    t.string "phone_number"
    t.string "contact_name"
    t.string "contact_lastname"
    t.string "email"
    t.string "rut"
    t.string "dpto"
    t.time "time_open"
    t.time "time_close"
    t.string "type_deliver"
    t.time "time_deliver_open"
    t.time "time_deliver_close"
    t.string "address_concat"
    t.string "complete_name"
    t.string "description"
    t.string "price_deliver"
    t.string "price"
    t.bigint "user_asign_id"
    t.string "order_number"
    t.bigint "company_id"
    t.integer "status_pay", default: 0
    t.bigint "deal_id"
    t.integer "default_price"
    t.datetime "date_deliver_at", precision: nil
    t.string "longitude"
    t.string "latitude"
    t.bigint "distance_meters", default: 100
    t.integer "integration_type"
    t.decimal "integration_order_id"
    t.string "provice"
    t.integer "shipping_without_payment"
    t.index ["branch_id"], name: "index_deliveries_on_branch_id"
    t.index ["company_id"], name: "index_deliveries_on_company_id"
    t.index ["deal_id"], name: "index_deliveries_on_deal_id"
  end

  create_table "deliveries_users", id: false, force: :cascade do |t|
    t.bigint "delivery_id", null: false
    t.bigint "user_id", null: false
    t.index ["delivery_id"], name: "index_deliveries_users_on_delivery_id"
    t.index ["user_id"], name: "index_deliveries_users_on_user_id"
  end

  create_table "driver_positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.float "destination_latitude"
    t.float "destination_longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_driver_positions_on_user_id", unique: true
  end

  create_table "integrations", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.integer "app_type"
    t.string "token"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_integrations_on_company_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "description"
    t.integer "amount"
    t.datetime "pay_date", precision: nil
    t.integer "payment_method_id"
    t.boolean "verified"
    t.text "response_json"
    t.string "flow_order"
    t.string "currency"
    t.string "payer"
    t.string "media"
    t.integer "status"
    t.integer "fee"
    t.integer "balance"
    t.datetime "transfer_date", precision: nil
    t.string "buy_order"
    t.string "session_id"
    t.string "status_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "deal_id"
    t.bigint "company_id"
    t.string "token"
    t.index ["company_id"], name: "index_payments_on_company_id"
    t.index ["deal_id"], name: "index_payments_on_deal_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "resources", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "web_address"
    t.boolean "is_valid", default: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "branch_id", null: false
    t.string "token"
    t.string "name"
    t.index ["branch_id"], name: "index_resources_on_branch_id"
    t.index ["company_id"], name: "index_resources_on_company_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "statuses", force: :cascade do |t|
    t.bigint "delivery_id", null: false
    t.integer "status"
    t.bigint "user_id", null: false
    t.string "image"
    t.string "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "receiver_name"
    t.string "receiver_rut"
    t.string "receiver_phone"
    t.index ["delivery_id"], name: "index_statuses_on_delivery_id"
  end

  create_table "user_accesses", force: :cascade do |t|
    t.integer "access_type"
    t.string "invitation_email"
    t.bigint "company_id", null: false
    t.bigint "user_id"
    t.boolean "is_valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_accesses_on_company_id"
    t.index ["user_id"], name: "index_user_accesses_on_user_id"
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "show_delivery", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "last_name"
    t.string "avatar"
    t.string "rut"
    t.integer "role", default: 0
    t.string "phone_number"
    t.integer "status", default: 0
    t.boolean "term_and_conditions", default: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.datetime "confirmed_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "withdrawal_receipts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.integer "sender_local_plain"
    t.integer "sender_local_check"
    t.integer "returned_amount"
    t.string "name_client"
    t.datetime "issued_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commune"
    t.integer "withdrawal_receipt_type", default: 0
    t.index ["company_id"], name: "index_withdrawal_receipts_on_company_id"
    t.index ["user_id"], name: "index_withdrawal_receipts_on_user_id"
  end

  add_foreign_key "archives", "users"
  add_foreign_key "branches", "companies"
  add_foreign_key "companies", "users"
  add_foreign_key "deals", "companies"
  add_foreign_key "deals", "users"
  add_foreign_key "deliveries", "branches"
  add_foreign_key "deliveries", "companies"
  add_foreign_key "deliveries", "deals"
  add_foreign_key "driver_positions", "users"
  add_foreign_key "payments", "companies"
  add_foreign_key "payments", "deals"
  add_foreign_key "payments", "users"
  add_foreign_key "resources", "branches"
  add_foreign_key "resources", "companies"
  add_foreign_key "statuses", "deliveries"
  add_foreign_key "user_accesses", "companies"
  add_foreign_key "user_accesses", "users"
  add_foreign_key "user_settings", "users"
  add_foreign_key "withdrawal_receipts", "companies"
  add_foreign_key "withdrawal_receipts", "users"
end
