# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_18_061946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_logs", id: :serial, force: :cascade do |t|
    t.integer "remotty_entry_id"
    t.integer "remotty_stats_entry_id"
    t.integer "remotty_gems_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_authentications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "nickname"
    t.string "image"
    t.string "access_token"
    t.string "secret_token"
    t.text "auth_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_check_logs", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "check_log_id"
    t.string "color", null: false
    t.integer "red_count", null: false
    t.integer "dependency_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "advisories"
    t.index ["check_log_id"], name: "index_project_check_logs_on_check_log_id"
    t.index ["project_id"], name: "index_project_check_logs_on_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "nickname"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "project_check_logs", "check_logs"
  add_foreign_key "project_check_logs", "projects"
end
