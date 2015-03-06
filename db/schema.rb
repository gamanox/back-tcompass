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

ActiveRecord::Schema.define(version: 20150209171352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrators", force: true do |t|
    t.integer "client_id"
    t.integer "employee_id"
  end

  create_table "branch_responses", force: true do |t|
    t.integer "branch_id"
    t.integer "response_id"
  end

  create_table "branches", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.string   "latlng",      default: "37.769421, 122.48612"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "phone"
    t.string   "email"
    t.boolean  "is_active",   default: true
  end

  create_table "employee_locations", force: true do |t|
    t.integer  "user_id"
    t.string   "latlng"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_type", default: 0
  end

  create_table "group_branches", force: true do |t|
    t.integer "group_id"
    t.integer "branch_id"
  end

  create_table "group_reports", force: true do |t|
    t.integer "group_id"
    t.integer "report_id"
  end

  create_table "groups", force: true do |t|
    t.integer "user_id"
    t.string  "name"
  end

  create_table "groups_users", force: true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  create_table "message_groups", force: true do |t|
    t.integer "group_id"
    t.integer "message_id"
  end

  create_table "message_statuses", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_ids",   default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.integer  "comment_id"
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.boolean  "is_read",    default: true
  end

  create_table "pages", force: true do |t|
    t.integer  "report_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: true do |t|
    t.integer  "page_id"
    t.integer  "question_type"
    t.string   "title"
    t.string   "options",       array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "skus",          array: true
  end

  create_table "reports", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",   default: true
  end

  create_table "responses", force: true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.integer  "question_type"
    t.string   "single_resp"
    t.string   "multiple_resp", array: true
    t.boolean  "bool_resp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_resp"
  end

  create_table "user_reports", force: true do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "users", force: true do |t|
    t.integer  "client_id"
    t.integer  "employee_id"
    t.string   "name"
    t.string   "last_name"
    t.string   "address"
    t.string   "location"
    t.integer  "qty_reports",     default: 1
    t.integer  "qty_employees",   default: 1
    t.time     "day_start"
    t.time     "day_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "password_digest"
    t.string   "token"
    t.integer  "qty_branches",    default: 1
    t.string   "soft_ver"
    t.date     "birthday"
    t.string   "phone"
    t.boolean  "is_active",       default: true
  end

end
