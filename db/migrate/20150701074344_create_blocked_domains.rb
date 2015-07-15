class CreateBlockedDomains < ActiveRecord::Migration
  def change
    create_table :blocked_domains do |t|
      t.string :names, array: true
      t.timestamps
      t.string "creator_str"
      t.string "updator_str"
    end

    create_table "log_blocked_domains", force: :cascade do |t|
      t.string "item_type", null: false
      t.integer "item_id", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.json "object"
      t.json "object_changes"
      t.datetime "created_at"
      t.string "session"
      t.json "children"
    end

    add_index "log_blocked_domains", ["item_type", "item_id"], name: "index_log_blocked_domains_on_item_type_and_item_id", using: :btree
    add_index "log_blocked_domains", ["whodunnit"], name: "index_log_blocked_domains_on_whodunnit", using: :btree
  end
end
