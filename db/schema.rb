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

ActiveRecord::Schema.define(version: 20140627082711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.integer  "contact_id"
    t.integer  "country_id"
    t.string   "city"
    t.string   "address"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "type"
    t.string   "reg_no"
    t.string   "phone"
    t.string   "email"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_id", force: true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", force: true do |t|
    t.string   "name"
    t.integer  "registrar_id"
    t.datetime "registered_at"
    t.string   "status"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.integer  "owner_contact_id"
    t.integer  "admin_contact_id"
    t.integer  "technical_contact_id"
    t.integer  "ns_set_id"
    t.string   "auth_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epp_sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "epp_sessions", ["session_id"], name: "index_epp_sessions_on_session_id", unique: true, using: :btree
  add_index "epp_sessions", ["updated_at"], name: "index_epp_sessions_on_updated_at", using: :btree

  create_table "epp_users", force: true do |t|
    t.integer  "registrar_id"
    t.string   "username"
    t.string   "password"
    t.boolean  "active",       default: false
    t.text     "csr"
    t.text     "crt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nameservers", force: true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "ns_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nameservers_ns_sets", force: true do |t|
    t.integer "nameserver_id"
    t.integer "ns_set_id"
  end

  create_table "ns_sets", force: true do |t|
    t.string   "code"
    t.integer  "registrar_id"
    t.string   "auth_info"
    t.string   "report_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrars", force: true do |t|
    t.string   "name"
    t.string   "reg_no"
    t.string   "vat_no"
    t.string   "address"
    t.integer  "country_id"
    t.string   "billing_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", force: true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights_roles", force: true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
