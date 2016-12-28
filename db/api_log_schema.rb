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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "epp_logs", force: :cascade do |t|
    t.text     "request"
    t.text     "response"
    t.string   "request_command",    limit: 255
    t.string   "request_object",     limit: 255
    t.boolean  "request_successful"
    t.string   "api_user_name",      limit: 255
    t.string   "api_user_registrar", limit: 255
    t.string   "ip",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  add_index "epp_logs", ["uuid"], name: "epp_logs_uuid", using: :btree

  create_table "repp_logs", force: :cascade do |t|
    t.string   "request_path",       limit: 255
    t.string   "request_method",     limit: 255
    t.text     "request_params"
    t.text     "response"
    t.string   "response_code",      limit: 255
    t.string   "api_user_name",      limit: 255
    t.string   "api_user_registrar", limit: 255
    t.string   "ip",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  add_index "repp_logs", ["uuid"], name: "repp_logs_uuid", using: :btree

end
