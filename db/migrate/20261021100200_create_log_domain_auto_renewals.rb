class CreateLogDomainAutoRenewals < ActiveRecord::Migration[6.1]
  def change
    create_table :log_domain_auto_renewals, id: :serial do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.json :object_changes
      t.datetime :created_at
      t.string :session
      t.json :children
      t.string :uuid

      t.index [:item_type, :item_id]
      t.index :whodunnit
    end
  end
end
