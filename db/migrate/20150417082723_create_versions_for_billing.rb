class CreateVersionsForBilling < ActiveRecord::Migration
  def change

    add_column :account_activities, :creator_str, :string
    add_column :account_activities, :updator_str, :string

    add_column :accounts, :creator_str, :string
    add_column :accounts, :updator_str, :string

    add_column :bank_statements, :creator_str, :string
    add_column :bank_statements, :updator_str, :string

    add_column :bank_transactions, :creator_str, :string
    add_column :bank_transactions, :updator_str, :string

    add_column :invoices, :creator_str, :string
    add_column :invoices, :updator_str, :string

    add_column :invoice_items, :creator_str, :string
    add_column :invoice_items, :updator_str, :string

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
    end

    add_index "log_accounts", ["item_type", "item_id"], name: "index_log_accounts_on_item_type_and_item_id", using: :btree
    add_index "log_accounts", ["whodunnit"], name: "index_log_accounts_on_whodunnit", using: :btree

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
    end

    add_index "log_bank_transactions", ["item_type", "item_id"], name: "index_log_bank_transactions_on_item_type_and_item_id", using: :btree
    add_index "log_bank_transactions", ["whodunnit"], name: "index_log_bank_transactions_on_whodunnit", using: :btree

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
    end

    add_index "log_invoices", ["item_type", "item_id"], name: "index_log_invoices_on_item_type_and_item_id", using: :btree
    add_index "log_invoices", ["whodunnit"], name: "index_log_invoices_on_whodunnit", using: :btree

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
    end

    add_index "log_invoice_items", ["item_type", "item_id"], name: "index_log_invoice_items_on_item_type_and_item_id", using: :btree
    add_index "log_invoice_items", ["whodunnit"], name: "index_log_invoice_items_on_whodunnit", using: :btree
  end
end
