class ContactAndVersionArchiving < ActiveRecord::Migration
  def change
    create_table :contact_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end

    create_table :address_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end

    add_index :contact_versions, [:item_type, :item_id]
    add_index :address_versions, [:item_type, :item_id]

  end
end
