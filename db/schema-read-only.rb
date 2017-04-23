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

ActiveRecord::Schema.define(version: 20170422162824) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gist"
  enable_extension "hstore"

  create_table "account_activities", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "invoice_id"
    t.decimal  "sum",                 precision: 10, scale: 2
    t.string   "currency"
    t.integer  "bank_transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "activity_type"
    t.integer  "log_pricelist_id"
  end

  add_index "account_activities", ["account_id"], name: "index_account_activities_on_account_id", using: :btree
  add_index "account_activities", ["bank_transaction_id"], name: "index_account_activities_on_bank_transaction_id", using: :btree
  add_index "account_activities", ["invoice_id"], name: "index_account_activities_on_invoice_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "account_type"
    t.decimal  "balance",      precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  add_index "accounts", ["registrar_id"], name: "index_accounts_on_registrar_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "contact_id"
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
    t.string   "state"
    t.integer  "legacy_contact_id"
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

  add_index "api_users", ["registrar_id"], name: "index_api_users_on_registrar_id", using: :btree

  create_table "bank_statements", force: :cascade do |t|
    t.string   "bank_code"
    t.string   "iban"
    t.string   "import_file_path"
    t.datetime "queried_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer  "bank_statement_id"
    t.string   "bank_reference"
    t.string   "iban"
    t.string   "currency"
    t.string   "buyer_bank_code"
    t.string   "buyer_iban"
    t.string   "buyer_name"
    t.string   "document_no"
    t.string   "description"
    t.decimal  "sum",               precision: 10, scale: 2
    t.string   "reference_no"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
    t.boolean  "in_directo",                                 default: false
  end

  create_table "banklink_transactions", force: :cascade do |t|
    t.string   "vk_service"
    t.string   "vk_version"
    t.string   "vk_snd_id"
    t.string   "vk_rec_id"
    t.string   "vk_stamp"
    t.string   "vk_t_no"
    t.decimal  "vk_amount",     precision: 10, scale: 2
    t.string   "vk_curr"
    t.string   "vk_rec_acc"
    t.string   "vk_rec_name"
    t.string   "vk_snd_acc"
    t.string   "vk_snd_name"
    t.string   "vk_ref"
    t.string   "vk_msg"
    t.datetime "vk_t_datetime"
    t.string   "vk_mac"
    t.string   "vk_encoding"
    t.string   "vk_lang"
    t.string   "vk_auto"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blocked_domains", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "name"
  end

  add_index "blocked_domains", ["name"], name: "index_blocked_domains_on_name", using: :btree

  create_table "business_registry_caches", force: :cascade do |t|
    t.string   "ident"
    t.string   "ident_country_code"
    t.datetime "retrieved_on"
    t.string   "associated_businesses",              array: true
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "business_registry_caches", ["ident"], name: "index_business_registry_caches_on_ident", using: :btree

  create_table "cached_nameservers", id: false, force: :cascade do |t|
    t.string "hostname", limit: 255
    t.string "ipv4",     limit: 255
    t.string "ipv6",     limit: 255
  end

  add_index "cached_nameservers", ["hostname", "ipv4", "ipv6"], name: "index_cached_nameservers_on_hostname_and_ipv4_and_ipv6", unique: true, using: :btree

  create_table "certificates", force: :cascade do |t|
    t.integer  "api_user_id"
    t.text     "csr"
    t.text     "crt"
    t.string   "creator_str"
    t.string   "updator_str"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "common_name"
    t.string   "md5"
    t.string   "interface"
  end

  add_index "certificates", ["api_user_id"], name: "index_certificates_on_api_user_id", using: :btree

  create_table "contact_statuses", force: :cascade do |t|
    t.string   "value"
    t.string   "description"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  add_index "contact_statuses", ["contact_id"], name: "index_contact_statuses_on_contact_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "code"
    t.string   "phone"
    t.string   "email"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ident"
    t.string   "ident_type"
    t.string   "auth_info"
    t.string   "name"
    t.string   "org_name"
    t.integer  "registrar_id"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "ident_country_code"
    t.string   "city"
    t.text     "street"
    t.string   "zip"
    t.string   "country_code"
    t.string   "state"
    t.integer  "legacy_id"
    t.string   "statuses",           default: [], array: true
    t.hstore   "status_notes"
    t.integer  "legacy_history_id"
    t.integer  "copy_from_id"
    t.datetime "ident_updated_at"
    t.integer  "upid"
    t.datetime "up_date"
  end

  add_index "contacts", ["code"], name: "index_contacts_on_code", using: :btree
  add_index "contacts", ["registrar_id", "ident_type"], name: "index_contacts_on_registrar_id_and_ident_type", using: :btree
  add_index "contacts", ["registrar_id"], name: "index_contacts_on_registrar_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "data_migrations", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  add_index "data_migrations", ["version"], name: "unique_data_migrations", unique: true, using: :btree

  create_table "delegation_signers", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "key_tag"
    t.integer "alg"
    t.integer "digest_type"
    t.string  "digest"
  end

  add_index "delegation_signers", ["domain_id"], name: "index_delegation_signers_on_domain_id", using: :btree

  create_table "depricated_versions", force: :cascade do |t|
    t.datetime "created_at"
  end

  create_table "directos", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.json     "response"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "invoice_number"
    t.text     "request"
  end

  add_index "directos", ["item_type", "item_id"], name: "index_directos_on_item_type_and_item_id", using: :btree

  create_table "dnskeys", force: :cascade do |t|
    t.integer  "domain_id"
    t.integer  "flags"
    t.integer  "protocol"
    t.integer  "alg"
    t.text     "public_key"
    t.integer  "delegation_signer_id"
    t.string   "ds_key_tag"
    t.integer  "ds_alg"
    t.integer  "ds_digest_type"
    t.string   "ds_digest"
    t.string   "creator_str"
    t.string   "updator_str"
    t.integer  "legacy_domain_id"
    t.datetime "updated_at"
  end

  add_index "dnskeys", ["delegation_signer_id"], name: "index_dnskeys_on_delegation_signer_id", using: :btree
  add_index "dnskeys", ["domain_id"], name: "index_dnskeys_on_domain_id", using: :btree
  add_index "dnskeys", ["legacy_domain_id"], name: "index_dnskeys_on_legacy_domain_id", using: :btree

  create_table "domain_contacts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "domain_id"
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_code_cache"
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "type"
    t.integer  "legacy_domain_id"
    t.integer  "legacy_contact_id"
  end

  add_index "domain_contacts", ["contact_id"], name: "index_domain_contacts_on_contact_id", using: :btree
  add_index "domain_contacts", ["domain_id"], name: "index_domain_contacts_on_domain_id", using: :btree

  create_table "domain_statuses", force: :cascade do |t|
    t.integer "domain_id"
    t.string  "description"
    t.string  "value"
    t.string  "creator_str"
    t.string  "updator_str"
    t.integer "legacy_domain_id"
  end

  add_index "domain_statuses", ["domain_id"], name: "index_domain_statuses_on_domain_id", using: :btree

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

  add_index "domain_transfers", ["domain_id"], name: "index_domain_transfers_on_domain_id", using: :btree

  create_table "domains", force: :cascade do |t|
    t.string   "name"
    t.integer  "registrar_id"
    t.datetime "registered_at"
    t.string   "status"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.integer  "registrant_id"
    t.string   "auth_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_dirty"
    t.string   "name_puny"
    t.integer  "period"
    t.string   "period_unit",                      limit: 1
    t.string   "creator_str"
    t.string   "updator_str"
    t.integer  "legacy_id"
    t.integer  "legacy_registrar_id"
    t.integer  "legacy_registrant_id"
    t.datetime "outzone_at"
    t.datetime "delete_at"
    t.datetime "registrant_verification_asked_at"
    t.string   "registrant_verification_token"
    t.json     "pending_json"
    t.datetime "force_delete_at"
    t.string   "statuses",                                                   array: true
    t.boolean  "reserved",                                   default: false
    t.hstore   "status_notes"
    t.string   "statuses_backup",                            default: [],    array: true
    t.integer  "upid"
    t.datetime "up_date"
  end

  add_index "domains", ["delete_at"], name: "index_domains_on_delete_at", using: :btree
  add_index "domains", ["name"], name: "index_domains_on_name", unique: true, using: :btree
  add_index "domains", ["outzone_at"], name: "index_domains_on_outzone_at", using: :btree
  add_index "domains", ["registrant_id"], name: "index_domains_on_registrant_id", using: :btree
  add_index "domains", ["registrant_verification_asked_at"], name: "index_domains_on_registrant_verification_asked_at", using: :btree
  add_index "domains", ["registrant_verification_token"], name: "index_domains_on_registrant_verification_token", using: :btree
  add_index "domains", ["registrar_id"], name: "index_domains_on_registrar_id", using: :btree
  add_index "domains", ["statuses"], name: "index_domains_on_statuses", using: :gin

  create_table "epp_sessions", force: :cascade do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registrar_id"
  end

  add_index "epp_sessions", ["session_id"], name: "index_epp_sessions_on_session_id", unique: true, using: :btree
  add_index "epp_sessions", ["updated_at"], name: "index_epp_sessions_on_updated_at", using: :btree

  create_table "invoice_items", force: :cascade do |t|
    t.integer  "invoice_id"
    t.string   "description",                          null: false
    t.string   "unit"
    t.integer  "amount"
    t.decimal  "price",       precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "invoice_type",                                                 null: false
    t.datetime "due_date",                                                     null: false
    t.string   "payment_term"
    t.string   "currency",                                                     null: false
    t.string   "description"
    t.string   "reference_no"
    t.decimal  "vat_prc",             precision: 10, scale: 2,                 null: false
    t.datetime "paid_at"
    t.integer  "seller_id"
    t.string   "seller_name",                                                  null: false
    t.string   "seller_reg_no"
    t.string   "seller_iban",                                                  null: false
    t.string   "seller_bank"
    t.string   "seller_swift"
    t.string   "seller_vat_no"
    t.string   "seller_country_code"
    t.string   "seller_state"
    t.string   "seller_street"
    t.string   "seller_city"
    t.string   "seller_zip"
    t.string   "seller_phone"
    t.string   "seller_url"
    t.string   "seller_email"
    t.string   "seller_contact_name"
    t.integer  "buyer_id"
    t.string   "buyer_name",                                                   null: false
    t.string   "buyer_reg_no"
    t.string   "buyer_country_code"
    t.string   "buyer_state"
    t.string   "buyer_street"
    t.string   "buyer_city"
    t.string   "buyer_zip"
    t.string   "buyer_phone"
    t.string   "buyer_url"
    t.string   "buyer_email"
    t.string   "creator_str"
    t.string   "updator_str"
    t.integer  "number"
    t.datetime "cancelled_at"
    t.decimal  "sum_cache",           precision: 10, scale: 2
    t.boolean  "in_directo",                                   default: false
  end

  add_index "invoices", ["buyer_id"], name: "index_invoices_on_buyer_id", using: :btree
  add_index "invoices", ["seller_id"], name: "index_invoices_on_seller_id", using: :btree

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

  add_index "keyrelays", ["accepter_id"], name: "index_keyrelays_on_accepter_id", using: :btree
  add_index "keyrelays", ["domain_id"], name: "index_keyrelays_on_domain_id", using: :btree
  add_index "keyrelays", ["requester_id"], name: "index_keyrelays_on_requester_id", using: :btree

  create_table "legal_documents", force: :cascade do |t|
    t.string   "document_type"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at"
    t.string   "creator_str"
    t.string   "path"
    t.string   "checksum"
  end

  add_index "legal_documents", ["checksum"], name: "index_legal_documents_on_checksum", using: :btree
  add_index "legal_documents", ["documentable_type", "documentable_id"], name: "index_legal_documents_on_documentable_type_and_documentable_id", using: :btree

  create_table "log_account_activities", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_account_activities", ["item_type", "item_id"], name: "index_log_account_activities_on_item_type_and_item_id", using: :btree
  add_index "log_account_activities", ["whodunnit"], name: "index_log_account_activities_on_whodunnit", using: :btree

  create_table "log_accounts", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_accounts", ["item_type", "item_id"], name: "index_log_accounts_on_item_type_and_item_id", using: :btree
  add_index "log_accounts", ["whodunnit"], name: "index_log_accounts_on_whodunnit", using: :btree

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
    t.string   "uuid"
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
    t.string   "uuid"
  end

  add_index "log_api_users", ["item_type", "item_id"], name: "index_log_api_users_on_item_type_and_item_id", using: :btree
  add_index "log_api_users", ["whodunnit"], name: "index_log_api_users_on_whodunnit", using: :btree

  create_table "log_bank_statements", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_bank_statements", ["item_type", "item_id"], name: "index_log_bank_statements_on_item_type_and_item_id", using: :btree
  add_index "log_bank_statements", ["whodunnit"], name: "index_log_bank_statements_on_whodunnit", using: :btree

  create_table "log_bank_transactions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_bank_transactions", ["item_type", "item_id"], name: "index_log_bank_transactions_on_item_type_and_item_id", using: :btree
  add_index "log_bank_transactions", ["whodunnit"], name: "index_log_bank_transactions_on_whodunnit", using: :btree

  create_table "log_blocked_domains", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_blocked_domains", ["item_type", "item_id"], name: "index_log_blocked_domains_on_item_type_and_item_id", using: :btree
  add_index "log_blocked_domains", ["whodunnit"], name: "index_log_blocked_domains_on_whodunnit", using: :btree

  create_table "log_certificates", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_certificates", ["item_type", "item_id"], name: "index_log_certificates_on_item_type_and_item_id", using: :btree
  add_index "log_certificates", ["whodunnit"], name: "index_log_certificates_on_whodunnit", using: :btree

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
    t.string   "uuid"
  end

  add_index "log_contact_statuses", ["item_type", "item_id"], name: "index_log_contact_statuses_on_item_type_and_item_id", using: :btree
  add_index "log_contact_statuses", ["whodunnit"], name: "index_log_contact_statuses_on_whodunnit", using: :btree

  create_table "log_contacts", force: :cascade do |t|
    t.string   "item_type",        null: false
    t.integer  "item_id",          null: false
    t.string   "event",            null: false
    t.string   "whodunnit"
    t.jsonb    "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.datetime "ident_updated_at"
    t.string   "uuid"
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
    t.string   "uuid"
  end

  add_index "log_countries", ["item_type", "item_id"], name: "index_log_countries_on_item_type_and_item_id", using: :btree
  add_index "log_countries", ["whodunnit"], name: "index_log_countries_on_whodunnit", using: :btree

  create_table "log_dnskeys", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.jsonb    "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
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
    t.string   "uuid"
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
    t.string   "uuid"
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
    t.string   "uuid"
  end

  add_index "log_domain_transfers", ["item_type", "item_id"], name: "index_log_domain_transfers_on_item_type_and_item_id", using: :btree
  add_index "log_domain_transfers", ["whodunnit"], name: "index_log_domain_transfers_on_whodunnit", using: :btree

  create_table "log_domains", force: :cascade do |t|
    t.string   "item_type",                      null: false
    t.integer  "item_id",                        null: false
    t.string   "event",                          null: false
    t.string   "whodunnit"
    t.jsonb    "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.text     "nameserver_ids",    default: [],              array: true
    t.text     "tech_contact_ids",  default: [],              array: true
    t.text     "admin_contact_ids", default: [],              array: true
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_domains", ["item_type", "item_id"], name: "index_log_domains_on_item_type_and_item_id", using: :btree
  add_index "log_domains", ["whodunnit"], name: "index_log_domains_on_whodunnit", using: :btree

  create_table "log_invoice_items", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_invoice_items", ["item_type", "item_id"], name: "index_log_invoice_items_on_item_type_and_item_id", using: :btree
  add_index "log_invoice_items", ["whodunnit"], name: "index_log_invoice_items_on_whodunnit", using: :btree

  create_table "log_invoices", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_invoices", ["item_type", "item_id"], name: "index_log_invoices_on_item_type_and_item_id", using: :btree
  add_index "log_invoices", ["whodunnit"], name: "index_log_invoices_on_whodunnit", using: :btree

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
    t.string   "uuid"
  end

  add_index "log_keyrelays", ["item_type", "item_id"], name: "index_log_keyrelays_on_item_type_and_item_id", using: :btree
  add_index "log_keyrelays", ["whodunnit"], name: "index_log_keyrelays_on_whodunnit", using: :btree

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
    t.string   "uuid"
  end

  add_index "log_messages", ["item_type", "item_id"], name: "index_log_messages_on_item_type_and_item_id", using: :btree
  add_index "log_messages", ["whodunnit"], name: "index_log_messages_on_whodunnit", using: :btree

  create_table "log_nameservers", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.jsonb    "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  add_index "log_nameservers", ["item_type", "item_id"], name: "index_log_nameservers_on_item_type_and_item_id", using: :btree
  add_index "log_nameservers", ["whodunnit"], name: "index_log_nameservers_on_whodunnit", using: :btree

  create_table "log_pricelists", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.string   "uuid"
  end

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
    t.string   "uuid"
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
    t.string   "uuid"
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
    t.string   "uuid"
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
    t.string   "uuid"
  end

  add_index "log_users", ["item_type", "item_id"], name: "index_log_users_on_item_type_and_item_id", using: :btree
  add_index "log_users", ["whodunnit"], name: "index_log_users_on_whodunnit", using: :btree

  create_table "log_white_ips", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.json     "object"
    t.json     "object_changes"
    t.datetime "created_at"
    t.string   "session"
    t.json     "children"
    t.string   "uuid"
  end

  create_table "mail_templates", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "subject"
    t.string   "from"
    t.string   "bcc"
    t.string   "cc"
    t.text     "body",       null: false
    t.text     "text_body",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "messages", ["registrar_id"], name: "index_messages_on_registrar_id", using: :btree

  create_table "nameservers", force: :cascade do |t|
    t.string   "hostname"
    t.string   "ipv4",             default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ipv6",             default: [], array: true
    t.integer  "domain_id"
    t.string   "creator_str"
    t.string   "updator_str"
    t.integer  "legacy_domain_id"
    t.string   "hostname_puny"
  end

  add_index "nameservers", ["domain_id"], name: "index_nameservers_on_domain_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["email"], name: "index_people_on_email", unique: true, using: :btree
  add_index "people", ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true, using: :btree

  create_table "pricelists", force: :cascade do |t|
    t.string   "desc"
    t.string   "category"
    t.decimal  "price_cents",        precision: 10, scale: 2, default: 0.0,   null: false
    t.string   "price_currency",                              default: "EUR", null: false
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string   "creator_str"
    t.string   "updator_str"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "duration"
    t.string   "operation_category"
  end

  create_table "que_jobs", id: false, force: :cascade do |t|
    t.integer  "priority",    limit: 2, default: 100,                                        null: false
    t.datetime "run_at",                default: "now()",                                    null: false
    t.integer  "job_id",      limit: 8, default: "nextval('que_jobs_job_id_seq'::regclass)", null: false
    t.text     "job_class",                                                                  null: false
    t.json     "args",                  default: [],                                         null: false
    t.integer  "error_count",           default: 0,                                          null: false
    t.text     "last_error"
    t.text     "queue",                 default: "",                                         null: false
  end

  create_table "registrant_verifications", force: :cascade do |t|
    t.string   "domain_name"
    t.string   "verification_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.integer  "domain_id"
    t.string   "action_type"
  end

  add_index "registrant_verifications", ["created_at"], name: "index_registrant_verifications_on_created_at", using: :btree
  add_index "registrant_verifications", ["domain_id"], name: "index_registrant_verifications_on_domain_id", using: :btree

  create_table "registrars", force: :cascade do |t|
    t.string   "name"
    t.string   "reg_no"
    t.string   "vat_no"
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
    t.string   "code"
    t.string   "website"
    t.string   "directo_handle"
    t.boolean  "vat"
    t.integer  "legacy_id"
    t.string   "reference_no"
    t.boolean  "exclude_in_monthly_directo", default: false
    t.boolean  "test_registrar",             default: false
  end

  add_index "registrars", ["code"], name: "index_registrars_on_code", using: :btree
  add_index "registrars", ["legacy_id"], name: "index_registrars_on_legacy_id", using: :btree

  create_table "reserved_domains", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
    t.integer  "legacy_id"
    t.string   "name"
    t.string   "password"
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
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "identity_code"
    t.string   "roles",                                         array: true
    t.string   "creator_str"
    t.string   "updator_str"
    t.string   "country_code"
    t.integer  "registrar_id"
    t.boolean  "active"
    t.text     "csr"
    t.text     "crt"
    t.string   "type"
    t.string   "registrant_ident"
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "failed_attempts",     default: 0,  null: false
    t.datetime "locked_at"
    t.integer  "legacy_id"
  end

  add_index "users", ["identity_code"], name: "index_users_on_identity_code", using: :btree
  add_index "users", ["registrar_id"], name: "index_users_on_registrar_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.text "depricated_table_but_somehow_paper_trail_tests_fails_without_it"
  end

  create_table "white_ips", force: :cascade do |t|
    t.integer  "registrar_id"
    t.string   "ipv4"
    t.string   "ipv6"
    t.string   "interfaces",   array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "creator_str"
    t.string   "updator_str"
  end

  create_table "whois_records", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "name"
    t.text     "body"
    t.json     "json"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "registrar_id"
  end

  add_index "whois_records", ["domain_id"], name: "index_whois_records_on_domain_id", using: :btree
  add_index "whois_records", ["registrar_id"], name: "index_whois_records_on_registrar_id", using: :btree

  create_table "zones", force: :cascade do |t|
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
    t.text     "ns_records"
    t.text     "a_records"
    t.text     "a4_records"
  end

end
