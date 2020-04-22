class CreateDisputes < ActiveRecord::Migration[5.2]
  def change
    create_table :disputes do |t|
      t.string :domain_name
      t.string :password
      t.date :expires_at
      t.date :starts_at
      t.text :comment
      t.datetime :created_at

      t.timestamps
    end
  end
end
