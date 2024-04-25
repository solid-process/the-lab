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

ActiveRecord::Schema[7.1].define(version: 2024_04_22_205854) do
  create_table "accounts", force: :cascade do |t|
    t.string "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_accounts_on_uuid", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.string "role", limit: 16, null: false
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_memberships_on_account_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "solid_process_event_logs", force: :cascade do |t|
    t.string "root_name", null: false
    t.string "trace_id"
    t.integer "version", null: false
    t.integer "duration", null: false
    t.json "ids", default: {}, null: false
    t.json "records", default: [], null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_solid_process_event_logs_on_created_at"
    t.index ["duration"], name: "index_solid_process_event_logs_on_duration"
    t.index ["root_name"], name: "index_solid_process_event_logs_on_root_name"
    t.index ["trace_id"], name: "index_solid_process_event_logs_on_trace_id"
  end

  create_table "task_lists", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "inbox", default: false, null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_task_lists_inbox", unique: true, where: "inbox"
    t.index ["account_id"], name: "index_task_lists_on_account_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "completed_at"
    t.integer "task_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_tasks_on_completed_at"
    t.index ["task_list_id"], name: "index_tasks_on_task_list_id"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.string "access_token", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_user_tokens_on_access_token", unique: true
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "memberships", "accounts"
  add_foreign_key "memberships", "users"
  add_foreign_key "task_lists", "accounts"
  add_foreign_key "tasks", "task_lists"
  add_foreign_key "user_tokens", "users"
end
