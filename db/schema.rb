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

ActiveRecord::Schema.define(version: 20150213104014) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "country_id"
    t.string   "city"
    t.string   "street"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street2"
    t.string   "street3"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "country_code"
  end

  create_table "api_users", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "username"
    t.string   "password"
    t.boolean  "active",       default: false
    t.text     "csr"
    t.text     "crt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
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
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "contact_statuses", force: :cascade do |t|
    t.string   "value"
    t.string   "description"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "contacts", force: :cascade do |t|
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
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "delayed_jobs", force: :cascade do |t|
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

  create_table "delegation_signers", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "key_tag"
    t.integer "alg"
    t.integer "digest_type"
    t.string  "digest"
  end

  create_table "depricated_versions", force: :cascade do |t|
    t.datetime "created_at"
  end

  create_table "dnskeys", force: :cascade do |t|
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
    t.string  "creator_str"
    t.string  "updator_str"
  end

  create_table "domain_contacts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "domain_id"
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_code_cache"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "domain_statuses", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "description"
    t.string  "value"
    t.string  "creator_str"
    t.string  "updator_str"
  end

  create_table "domain_transfers", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "status"
    t.datetime "transfer_requested_at"
    t.datetime "transferred_at"
    t.integer  "transfer_from_id"
    t.integer  "transfer_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "wait_until"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "domains", force: :cascade do |t|
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
    t.string   "creator_str"
    t.string   "updator_str"
    t.text     "whois_body"
  end

  create_table "epp_sessions", force: :cascade do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "epp_sessions", ["session_id"], name: "index_epp_sessions_on_session_id", unique: true, using: :btree
  add_index "epp_sessions", ["updated_at"], name: "index_epp_sessions_on_updated_at", using: :btree

  create_table "keyrelays", force: :cascade do |t|
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
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "legal_documents", force: :cascade do |t|
    t.string   "document_type"
    t.text     "body"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "log_addresses", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_addresses", ["item_type", "item_id"], name: "index_log_addresses_on_item_type_and_item_id", using: :btree
  add_index "log_addresses", ["whodunnit"], name: "index_log_addresses_on_whodunnit", using: :btree

  create_table "log_api_users", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_api_users", ["item_type", "item_id"], name: "index_log_api_users_on_item_type_and_item_id", using: :btree
  add_index "log_api_users", ["whodunnit"], name: "index_log_api_users_on_whodunnit", using: :btree

  create_table "log_contact_disclosures", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_contact_disclosures", ["item_type", "item_id"], name: "index_log_contact_disclosures_on_item_type_and_item_id", using: :btree
  add_index "log_contact_disclosures", ["whodunnit"], name: "index_log_contact_disclosures_on_whodunnit", using: :btree

  create_table "log_contact_statuses", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_contact_statuses", ["item_type", "item_id"], name: "index_log_contact_statuses_on_item_type_and_item_id", using: :btree
  add_index "log_contact_statuses", ["whodunnit"], name: "index_log_contact_statuses_on_whodunnit", using: :btree

  create_table "log_contacts", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_contacts", ["item_type", "item_id"], name: "index_log_contacts_on_item_type_and_item_id", using: :btree
  add_index "log_contacts", ["whodunnit"], name: "index_log_contacts_on_whodunnit", using: :btree

  create_table "log_countries", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_countries", ["item_type", "item_id"], name: "index_log_countries_on_item_type_and_item_id", using: :btree
  add_index "log_countries", ["whodunnit"], name: "index_log_countries_on_whodunnit", using: :btree

  create_table "log_dnskeys", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_dnskeys", ["item_type", "item_id"], name: "index_log_dnskeys_on_item_type_and_item_id", using: :btree
  add_index "log_dnskeys", ["whodunnit"], name: "index_log_dnskeys_on_whodunnit", using: :btree

  create_table "log_domain_contacts", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_domain_contacts", ["item_type", "item_id"], name: "index_log_domain_contacts_on_item_type_and_item_id", using: :btree
  add_index "log_domain_contacts", ["whodunnit"], name: "index_log_domain_contacts_on_whodunnit", using: :btree

  create_table "log_domain_statuses", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_domain_statuses", ["item_type", "item_id"], name: "index_log_domain_statuses_on_item_type_and_item_id", using: :btree
  add_index "log_domain_statuses", ["whodunnit"], name: "index_log_domain_statuses_on_whodunnit", using: :btree

  create_table "log_domain_transfers", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_domain_transfers", ["item_type", "item_id"], name: "index_log_domain_transfers_on_item_type_and_item_id", using: :btree
  add_index "log_domain_transfers", ["whodunnit"], name: "index_log_domain_transfers_on_whodunnit", using: :btree

  create_table "log_domains", force: :cascade do |t|
    t.string   "item_type",                      null: false
    t.integer  "item_id",                        null: false
    t.string   "event",                          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.text     "nameserver_ids",    default: [],              array: true
    t.text     "tech_contact_ids",  default: [],              array: true
    t.text     "admin_contact_ids", default: [],              array: true
    t.string   "session"
    t.json     "children"
  end

  add_index "log_domains", ["item_type", "item_id"], name: "index_log_domains_on_item_type_and_item_id", using: :btree
  add_index "log_domains", ["whodunnit"], name: "index_log_domains_on_whodunnit", using: :btree

  create_table "log_keyrelays", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_keyrelays", ["item_type", "item_id"], name: "index_log_keyrelays_on_item_type_and_item_id", using: :btree
  add_index "log_keyrelays", ["whodunnit"], name: "index_log_keyrelays_on_whodunnit", using: :btree

  create_table "log_legal_documents", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_legal_documents", ["item_type", "item_id"], name: "index_log_legal_documents_on_item_type_and_item_id", using: :btree
  add_index "log_legal_documents", ["whodunnit"], name: "index_log_legal_documents_on_whodunnit", using: :btree

  create_table "log_messages", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_messages", ["item_type", "item_id"], name: "index_log_messages_on_item_type_and_item_id", using: :btree
  add_index "log_messages", ["whodunnit"], name: "index_log_messages_on_whodunnit", using: :btree

  create_table "log_nameservers", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_nameservers", ["item_type", "item_id"], name: "index_log_nameservers_on_item_type_and_item_id", using: :btree
  add_index "log_nameservers", ["whodunnit"], name: "index_log_nameservers_on_whodunnit", using: :btree

  create_table "log_registrars", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_registrars", ["item_type", "item_id"], name: "index_log_registrars_on_item_type_and_item_id", using: :btree
  add_index "log_registrars", ["whodunnit"], name: "index_log_registrars_on_whodunnit", using: :btree

  create_table "log_reserved_domains", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_reserved_domains", ["item_type", "item_id"], name: "index_log_reserved_domains_on_item_type_and_item_id", using: :btree
  add_index "log_reserved_domains", ["whodunnit"], name: "index_log_reserved_domains_on_whodunnit", using: :btree

  create_table "log_settings", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_settings", ["item_type", "item_id"], name: "index_log_settings_on_item_type_and_item_id", using: :btree
  add_index "log_settings", ["whodunnit"], name: "index_log_settings_on_whodunnit", using: :btree

  create_table "log_users", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_users", ["item_type", "item_id"], name: "index_log_users_on_item_type_and_item_id", using: :btree
  add_index "log_users", ["whodunnit"], name: "index_log_users_on_whodunnit", using: :btree

  create_table "log_zonefile_settings", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
  end

  add_index "log_zonefile_settings", ["item_type", "item_id"], name: "index_log_zonefile_settings_on_item_type_and_item_id", using: :btree
  add_index "log_zonefile_settings", ["whodunnit"], name: "index_log_zonefile_settings_on_whodunnit", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "body"
    t.string   "attached_obj_type"
    t.string   "attached_obj_id"
    t.boolean  "queued"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "nameservers", force: :cascade do |t|
    t.string   "hostname"
    t.string   "ipv4"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ipv6"
    t.integer  "domain_id"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "registrars", force: :cascade do |t|
    t.string   "name"
    t.string   "reg_no"
    t.string   "vat_no"
    t.integer  "country_id"
    t.string   "billing_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "phone"
    t.string   "email"
    t.string   "billing_email"
    t.string   "country_code"
    t.string   "state"
    t.string   "city"
    t.string   "street"
    t.string   "zip"
  end

  create_table "reserved_domains", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                    null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type",  limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "sign_in_count",      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "identity_code"
    t.integer  "country_id"
    t.string   "roles",                                           array: true
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "country_code"
    t.integer  "registrar_id"
    t.boolean  "active",             default: false
    t.text     "csr"
    t.text     "crt"
    t.string   "type"
  end

  create_table "versions", force: :cascade do |t|
    t.text "depricated_table_but_somehow_paper_trail_tests_fails_without_it"
  end

  create_table "zonefile_settings", force: :cascade do |t|
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
    t.string   "creator_str"
    t.string   "updator_str"
  end

end
