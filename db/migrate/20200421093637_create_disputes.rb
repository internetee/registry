class CreateDisputes < ActiveRecord::Migration[5.2]
  def change
    create_table :disputes do |t|
      t.string :domain_name, null: false
      t.string :password, null: false
      t.date :expires_at, null: false
      t.date :starts_at, null: false
      t.text :comment
      t.boolean :closed, null: false, default: false

      t.timestamps
    end
  end
end
