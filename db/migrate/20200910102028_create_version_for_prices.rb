class CreateVersionForPrices < ActiveRecord::Migration[6.0]
  def up
    create_table :log_prices, force: :cascade do |t|
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

    add_index 'log_prices', ['item_type', 'item_id'], name: 'index_log_prices_on_item_type_and_item_id', using: :btree
    add_index 'log_prices', ['whodunnit'], name: 'index_log_prices_on_whodunnit', using: :btree
  end

  def down
    remove_index :log_prices, name: 'index_log_prices_on_item_type_and_item_id'
    remove_index :log_prices, name: 'index_log_prices_on_whodunnit'

    drop_table :log_prices
  end
end
