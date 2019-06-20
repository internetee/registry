class CreateLogActions < ActiveRecord::Migration
  def change
    create_table :log_actions do |t|
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
