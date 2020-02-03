class CreatePaymentOrderVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :log_payment_orders do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.jsonb :object_changes
      t.datetime :created_at
      t.string :session
      t.jsonb :children
      t.string :uuid
    end
  end
end
