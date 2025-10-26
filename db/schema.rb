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

ActiveRecord::Schema[8.1].define(version: 2025_10_26_215629) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "business_ownerships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["business_id"], name: "index_business_ownerships_on_business_id"
    t.index ["user_id", "business_id"], name: "index_business_ownerships_on_user_id_and_business_id", unique: true
    t.index ["user_id"], name: "index_business_ownerships_on_user_id"
  end

  create_table "businesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "calls_included", null: false
    t.integer "calls_used_this_period", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "plan", null: false
    t.string "status", default: "active", null: false
    t.string "stripe_customer_id", null: false
    t.string "stripe_subscription_id"
    t.uuid "trial_id"
    t.datetime "updated_at", null: false
    t.string "vapi_assistant_id"
    t.index ["plan"], name: "index_businesses_on_plan"
    t.index ["status"], name: "index_businesses_on_status"
    t.index ["stripe_customer_id"], name: "index_businesses_on_stripe_customer_id", unique: true
    t.index ["stripe_subscription_id"], name: "idx_businesses_unique_stripe_subscription_id", unique: true, where: "(stripe_subscription_id IS NOT NULL)"
    t.index ["stripe_subscription_id"], name: "index_businesses_on_stripe_subscription_id"
    t.index ["trial_id"], name: "index_businesses_on_trial_id"
    t.index ["vapi_assistant_id"], name: "index_businesses_on_vapi_assistant_id"
  end

  create_table "calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "callable_id", null: false
    t.string "callable_type", null: false
    t.jsonb "captured", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.integer "duration_seconds"
    t.datetime "ended_at", precision: nil
    t.jsonb "extracted_lead", default: {}
    t.string "from_e164"
    t.string "intent"
    t.uuid "lead_id"
    t.decimal "openai_cost", precision: 8, scale: 4
    t.string "recording_url"
    t.string "scenario_slug"
    t.datetime "started_at", precision: nil
    t.string "status", default: "initiated", null: false
    t.string "to_e164", null: false
    t.text "transcript"
    t.string "twilio_call_sid"
    t.decimal "twilio_cost", precision: 8, scale: 4
    t.datetime "updated_at", null: false
    t.string "vapi_call_id"
    t.decimal "vapi_cost", precision: 8, scale: 4
    t.index ["callable_type", "callable_id", "created_at"], name: "index_calls_on_callable_type_and_callable_id_and_created_at"
    t.index ["callable_type", "callable_id"], name: "index_calls_on_callable"
    t.index ["captured"], name: "index_calls_on_captured", using: :gin
    t.index ["created_at"], name: "index_calls_on_created_at"
    t.index ["direction"], name: "index_calls_on_direction"
    t.index ["intent"], name: "index_calls_on_intent"
    t.index ["lead_id"], name: "index_calls_on_lead_id"
    t.index ["scenario_slug"], name: "index_calls_on_scenario_slug"
    t.index ["status"], name: "index_calls_on_status"
    t.index ["twilio_call_sid"], name: "index_calls_on_twilio_call_sid", unique: true, where: "(twilio_call_sid IS NOT NULL)"
    t.index ["vapi_call_id"], name: "index_calls_on_vapi_call_id", unique: true, where: "(vapi_call_id IS NOT NULL)"
  end

  create_table "email_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "consent_ip"
    t.text "consent_user_agent"
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.boolean "marketing_consent", default: false, null: false
    t.string "source", default: "trial_signup", null: false
    t.datetime "subscribed_at", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["email"], name: "index_email_subscriptions_on_email", unique: true
    t.index ["source"], name: "index_email_subscriptions_on_source"
    t.index ["subscribed_at"], name: "index_email_subscriptions_on_subscribed_at"
    t.index ["user_id"], name: "index_email_subscriptions_on_user_id"
  end

  create_table "knowledge_bases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "industry", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["industry", "active"], name: "index_knowledge_bases_on_industry_and_active"
    t.index ["industry", "category", "priority"], name: "index_knowledge_bases_on_industry_and_category_and_priority"
    t.index ["industry"], name: "index_knowledge_bases_on_industry"
  end

  create_table "phone_numbers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "area_code"
    t.uuid "business_id", null: false
    t.jsonb "capabilities", default: {}
    t.string "country", default: "US", null: false
    t.datetime "created_at", null: false
    t.string "e164", null: false
    t.string "twilio_sid", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_phone_numbers_on_business_id"
    t.index ["e164"], name: "index_phone_numbers_on_e164", unique: true
    t.index ["twilio_sid"], name: "index_phone_numbers_on_twilio_sid", unique: true
  end

  create_table "scenario_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.text "notes"
    t.jsonb "prompt_pack", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "version", null: false
    t.index ["key", "active"], name: "idx_unique_active_scenario_template", unique: true, where: "(active = true)"
    t.index ["key"], name: "index_scenario_templates_on_key"
  end

  create_table "stripe_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "base_price_cents", null: false
    t.integer "calls_included", null: false
    t.datetime "created_at", null: false
    t.integer "overage_cents_per_call", null: false
    t.string "plan_name", null: false
    t.string "stripe_price_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_stripe_plans_on_active"
    t.index ["plan_name"], name: "index_stripe_plans_on_plan_name", unique: true
    t.index ["stripe_price_id"], name: "index_stripe_plans_on_stripe_price_id", unique: true
  end

  create_table "trials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "assistant_config", default: {}
    t.string "business_name", null: false
    t.integer "calls_limit", default: 3, null: false
    t.integer "calls_used", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "industry", null: false
    t.string "phone_e164", null: false
    t.datetime "ready_at", precision: nil
    t.string "scenario", null: false
    t.uuid "scenario_template_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "vapi_assistant_id"
    t.index ["expires_at"], name: "index_trials_on_expires_at"
    t.index ["ready_at"], name: "index_trials_on_ready_at"
    t.index ["scenario_template_id"], name: "index_trials_on_scenario_template_id"
    t.index ["status"], name: "index_trials_on_status"
    t.index ["user_id", "created_at"], name: "index_trials_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_trials_on_user_id"
    t.index ["vapi_assistant_id"], name: "index_trials_on_vapi_assistant_id"
    t.check_constraint "calls_used <= calls_limit", name: "chk_calls_within_limit"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin", where: "(admin = true)"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at", precision: nil
    t.string "provider", null: false
    t.integer "retries", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_webhook_events_on_created_at"
    t.index ["event_type"], name: "index_webhook_events_on_event_type"
    t.index ["provider", "event_id"], name: "idx_unique_webhook_event", unique: true
    t.index ["provider"], name: "index_webhook_events_on_provider"
    t.index ["status"], name: "index_webhook_events_on_status"
  end

  add_foreign_key "business_ownerships", "businesses"
  add_foreign_key "business_ownerships", "users"
  add_foreign_key "businesses", "trials"
  add_foreign_key "email_subscriptions", "users"
  add_foreign_key "phone_numbers", "businesses"
  add_foreign_key "trials", "scenario_templates"
  add_foreign_key "trials", "users"
end
