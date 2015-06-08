class AddPricelist < ActiveRecord::Migration
  def change
    create_table :pricelists do |t|
      t.string   :name
      t.string   :category
      t.monetize :price
      t.datetime :valid_from
      t.datetime :valid_to
      t.string   :creator_str
      t.string   :updator_str
      t.timestamps null: false
    end

    create_table :log_pricelists do |t|
      t.string   :item_type,      null: false
      t.integer  :item_id,        null: false
      t.string   :event,          null: false
      t.string   :whodunnit
      t.json     :object
      t.json     :object_changes
      t.datetime :created_at
      t.string   :session
    end
  end
end
