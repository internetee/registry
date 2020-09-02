class CreateVersionsForSettingEntries < ActiveRecord::Migration[6.0]
  def up
    create_table :log_setting_entries, force: :cascade do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.json :object
      t.json :object_changes
      t.datetime :created_at
      t.string :session
      t.json :children
      t.string :uuid
    end

    add_index 'log_setting_entries', ['item_type', 'item_id'], name: 'index_log_setting_entries_on_item_type_and_item_id', using: :btree
    add_index 'log_setting_entries', ['whodunnit'], name: 'index_log_setting_entries_on_whodunnit', using: :btree
  end

  def down
    remove_index :log_setting_entries, name: 'index_log_setting_entries_on_item_type_and_item_id'
    remove_index :log_setting_entries, name: 'index_log_setting_entries_on_whodunnit'

    drop_table :log_setting_entries
  end
end
