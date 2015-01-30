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

ActiveRecord::Schema.define(version: 20150130085458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "address_versions", ["item_type", "item_id"], name: "index_address_versions_on_item_type_and_item_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "country_id"
    t.string   "city",       limit: 255
    t.string   "street",     limit: 255
    t.string   "zip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street2",    limit: 255
    t.string   "street3",    limit: 255
  end

  create_table "api_users", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "username",     limit: 255
    t.string   "password",     limit: 255
    t.boolean  "active",                   default: false
    t.text     "csr"
    t.text     "crt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_nameservers", id: false, force: :cascade do |t|
    t.string "hostname", limit: 255
    t.string "ipv4",     limit: 255
    t.string "ipv6",     limit: 255
  end

  add_index "cached_nameservers", ["hostname", "ipv4", "ipv6"], name: "index_cached_nameservers_on_hostname_and_ipv4_and_ipv6", unique: true, using: :btree

  create_table "contact_disclosures", force: :cascade do |t|
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

  create_table "contact_statuses", force: :cascade do |t|
    t.string   "value",       limit: 255
    t.string   "description", limit: 255
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "contact_versions", ["item_type", "item_id"], name: "index_contact_versions_on_item_type_and_item_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "code",          limit: 255
    t.string   "type",          limit: 255
    t.string   "reg_no",        limit: 255
    t.string   "phone",         limit: 255
    t.string   "email",         limit: 255
    t.string   "fax",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident",         limit: 255
    t.string   "ident_type",    limit: 255
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "auth_info",     limit: 255
    t.string   "name",          limit: 255
    t.string   "org_name",      limit: 255
    t.integer  "registrar_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso",        limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delegation_signers", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "key_tag",     limit: 255
    t.integer "alg"
    t.integer "digest_type"
    t.string  "digest",      limit: 255
  end

  create_table "dnskeys", force: :cascade do |t|
    t.integer "domain_id"
    t.integer "flags"
    t.integer "protocol"
    t.integer "alg"
    t.text    "public_key"
    t.integer "delegation_signer_id"
    t.string  "ds_key_tag",           limit: 255
    t.integer "ds_alg"
    t.integer "ds_digest_type"
    t.string  "ds_digest",            limit: 255
  end

  create_table "domain_contacts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "domain_id"
    t.string   "contact_type",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_code_cache", limit: 255
  end

  create_table "domain_status_versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "domain_status_versions", ["item_type", "item_id"], name: "index_domain_status_versions_on_item_type_and_item_id", using: :btree

  create_table "domain_statuses", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "description", limit: 255
    t.string  "value",       limit: 255
  end

  create_table "domain_transfers", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "status",                limit: 255
    t.datetime "transfer_requested_at"
    t.datetime "transferred_at"
    t.integer  "transfer_from_id"
    t.integer  "transfer_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "wait_until"
  end

  create_table "domain_versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "snapshot"
  end

  add_index "domain_versions", ["item_type", "item_id"], name: "index_domain_versions_on_item_type_and_item_id", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "registrar_id"
    t.datetime "registered_at"
    t.string   "status",           limit: 255
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.integer  "owner_contact_id"
    t.string   "auth_info",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_dirty",       limit: 255
    t.string   "name_puny",        limit: 255
    t.integer  "period"
    t.string   "period_unit",      limit: 1
  end

  create_table "epp_sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "epp_sessions", ["session_id"], name: "index_epp_sessions_on_session_id", unique: true, using: :btree
  add_index "epp_sessions", ["updated_at"], name: "index_epp_sessions_on_updated_at", using: :btree

  create_table "keyrelays", force: :cascade do |t|
    t.integer  "domain_id"
    t.datetime "pa_date"
    t.string   "key_data_flags",      limit: 255
    t.string   "key_data_protocol",   limit: 255
    t.string   "key_data_alg",        limit: 255
    t.text     "key_data_public_key"
    t.string   "auth_info_pw",        limit: 255
    t.string   "expiry_relative",     limit: 255
    t.datetime "expiry_absolute"
    t.integer  "requester_id"
    t.integer  "accepter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "legal_documents", force: :cascade do |t|
    t.string   "document_type",     limit: 255
    t.text     "body"
    t.integer  "documentable_id"
    t.string   "documentable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "body",              limit: 255
    t.string   "attached_obj_type", limit: 255
    t.string   "attached_obj_id",   limit: 255
    t.boolean  "queued"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nameserver_versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "nameserver_versions", ["item_type", "item_id"], name: "index_nameserver_versions_on_item_type_and_item_id", using: :btree

  create_table "nameservers", force: :cascade do |t|
    t.string   "hostname",   limit: 255
    t.string   "ipv4",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ipv6",       limit: 255
    t.integer  "domain_id"
  end

  create_table "registrars", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "reg_no",          limit: 255
    t.string   "vat_no",          limit: 255
    t.string   "address",         limit: 255
    t.integer  "country_id"
    t.string   "billing_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "email"
    t.string   "billing_email"
  end

  create_table "reserved_domains", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255, null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "password",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",              limit: 255
    t.integer  "sign_in_count",                  default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "identity_code",      limit: 255
    t.integer  "country_id"
    t.string   "roles",                                                   array: true
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.integer  "transaction_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

  create_table "zonefile_settings", force: :cascade do |t|
    t.string   "origin",            limit: 255
    t.integer  "ttl"
    t.integer  "refresh"
    t.integer  "retry"
    t.integer  "expire"
    t.integer  "minimum_ttl"
    t.string   "email",             limit: 255
    t.string   "master_nameserver", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
