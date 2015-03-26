# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150326032938) do

  create_table "box_accesses", force: true do |t|
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "last_refresh"
    t.string   "user_email"
    t.boolean  "notifications_enabled"
  end

  create_table "box_documents", force: true do |t|
    t.string   "etag"
    t.string   "box_file_id"
    t.string   "box_view_id"
    t.string   "name"
    t.string   "box_session_id"
    t.datetime "box_session_expiration"
    t.date     "filing_date"
    t.date     "upload_date"
    t.integer  "category"
    t.string   "download_url"
    t.integer  "quarter"
    t.integer  "year"
    t.integer  "month"
    t.integer  "fund"
    t.string   "fund_tag"
    t.string   "visibility_tag"
    t.string   "entity_name"
  end

  create_table "document_views", force: true do |t|
    t.integer  "user_id"
    t.integer  "box_document_id"
    t.datetime "opened_at"
    t.datetime "downloaded_at"
    t.datetime "viewed_at"
  end

  create_table "entities", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fund_memberships", force: true do |t|
    t.integer  "entity_id"
    t.integer  "fund"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sync_entries", force: true do |t|
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer  "total_files"
    t.integer  "added_files"
    t.integer  "removed_files"
    t.string   "failure"
  end

  create_table "sync_entry", force: true do |t|
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer  "total_files"
    t.integer  "added_files"
    t.integer  "removed_files"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.integer  "entity_id"
    t.boolean  "enabled",                default: true
    t.datetime "activation_sent_at"
    t.string   "activation_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
