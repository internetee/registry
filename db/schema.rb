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

ActiveRecord::Schema.define(version: 20141216133831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "address_versions", ["item_type", "item_id"], name: "index_address_versions_on_item_type_and_item_id", using: :btree

  create_table "addresses", force: true do |t|
    t.integer  "contact_id"
    t.integer  "country_id"
    t.string   "city"
    t.string   "street"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street2"
    t.string   "street3"
  end

  create_table "cached_nameservers", id: false, force: true do |t|
    t.string "hostname"
    t.string "ipv4"
    t.string "ipv6"
  end

  add_index "cached_nameservers", ["hostname", "ipv4", "ipv6"], name: "index_cached_nameservers_on_hostname_and_ipv4_and_ipv6", unique: true, using: :btree

  create_table "contact_disclosures", force: true do |t|
    t.integer  "contact_id"
    t.boolean  "phone"
    t.boolean  "fax"
    t.boolean  "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "name"
    t.boolean  "org_name"
    t.boolean  "address"
  end

  create_table "contact_versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "contact_versions", ["item_type", "item_id"], name: "index_contact_versions_on_item_type_and_item_id", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "code"
    t.string   "type"
    t.string   "reg_no"
    t.string   "phone"
    t.string   "email"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
    t.string   "ident_type"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "auth_info"
    t.string   "name"
    t.string   "org_name"
    t.integer  "registrar_id"
  end

  create_table "countries", force: true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delegation_signers", force: true do |t|
    t.integer "domain_id"
    t.string  "key_tag"
    t.integer "alg"
    t.integer "digest_type"
    t.string  "digest"
  end

  create_table "dnskeys", force: true do |t|
    t.integer "domain_id"
    t.integer "flags"
    t.integer "protocol"
    t.integer "alg"
    t.text    "public_key"
    t.integer "delegation_signer_id"
    t.string  "ds_key_tag"
    t.integer "ds_alg"
    t.integer "ds_digest_type"
    t.string  "ds_digest"
  end

  create_table "domain_contacts", force: true do |t|
    t.integer  "contact_id"
    t.integer  "domain_id"
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_code_cache"
  end

  create_table "domain_status_versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "domain_status_versions", ["item_type", "item_id"], name: "index_domain_status_versions_on_item_type_and_item_id", using: :btree

  create_table "domain_statuses", force: true do |t|
    t.integer "domain_id"
    t.string  "description"
    t.string  "value"
  end

  create_table "domain_transfers", force: true do |t|
    t.integer  "domain_id"
    t.string   "status"
    t.datetime "transfer_requested_at"
    t.datetime "transferred_at"
    t.integer  "transfer_from_id"
    t.integer  "transfer_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "wait_until"
  end

  create_table "domain_versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "snapshot"
  end

  add_index "domain_versions", ["item_type", "item_id"], name: "index_domain_versions_on_item_type_and_item_id", using: :btree

  create_table "domains", force: true do |t|
    t.string   "name"
    t.integer  "registrar_id"
    t.datetime "registered_at"
    t.string   "status"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.integer  "owner_contact_id"
    t.string   "auth_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_dirty"
    t.string   "name_puny"
    t.integer  "period"
    t.string   "period_unit",      limit: 1
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

  create_table "keyrelays", force: true do |t|
    t.integer  "domain_id"
    t.datetime "pa_date"
    t.string   "key_data_flags"
    t.string   "key_data_protocol"
    t.string   "key_data_alg"
    t.text     "key_data_public_key"
    t.string   "auth_info_pw"
    t.string   "expiry_relative"
    t.datetime "expiry_absolute"
    t.integer  "requester_id"
    t.integer  "accepter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.integer  "registrar_id"
    t.string   "body"
    t.string   "attached_obj_type"
    t.string   "attached_obj_id"
    t.boolean  "queued"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nameserver_versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "nameserver_versions", ["item_type", "item_id"], name: "index_nameserver_versions_on_item_type_and_item_id", using: :btree

  create_table "nameservers", force: true do |t|
    t.string   "hostname"
    t.string   "ipv4"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ipv6"
    t.integer  "domain_id"
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

  create_table "reserved_domains", force: true do |t|
    t.string   "name"
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

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "sign_in_count",      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",              default: false
    t.string   "identity_code"
    t.integer  "country_id"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "zonefile_settings", force: true do |t|
    t.string   "origin"
    t.integer  "ttl"
    t.integer  "refresh"
    t.integer  "retry"
    t.integer  "expire"
    t.integer  "minimum_ttl"
    t.string   "email"
    t.string   "master_nameserver"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
