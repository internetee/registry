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

ActiveRecord::Schema.define(version: 20181102124618) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ar_internal_metadata", primary_key: "key", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_requests", id: :bigserial, force: :cascade do |t|
    t.integer  "whois_record_id",                 null: false
    t.string   "secret",                          null: false
    t.string   "email",                           null: false
    t.string   "name",                            null: false
    t.datetime "valid_to",                        null: false
    t.string   "status",          default: "new", null: false
    t.inet     "ip_address"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "contact_requests", ["email"], name: "index_contact_requests_on_email", using: :btree
  add_index "contact_requests", ["ip_address"], name: "index_contact_requests_on_ip_address", using: :btree
  add_index "contact_requests", ["secret"], name: "index_contact_requests_on_secret", unique: true, using: :btree
  add_index "contact_requests", ["whois_record_id"], name: "index_contact_requests_on_whois_record_id", using: :btree

  create_table "whois_records", force: :cascade do |t|
    t.string   "name"
    t.text     "body"
    t.json     "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "whois_records", ["name"], name: "index_domains_on_name", using: :btree

end
