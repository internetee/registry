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

ActiveRecord::Schema.define(version: 2018_11_02_124618) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contact_requests", force: :cascade do |t|
    t.integer "whois_record_id", null: false
    t.string "secret", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "valid_to", null: false
    t.string "status", default: "new", null: false
    t.inet "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_contact_requests_on_email"
    t.index ["ip_address"], name: "index_contact_requests_on_ip_address"
    t.index ["secret"], name: "index_contact_requests_on_secret", unique: true
    t.index ["whois_record_id"], name: "index_contact_requests_on_whois_record_id"
  end

  create_table "whois_records", force: :cascade do |t|
    t.string "name"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_domains_on_name"
  end

end
