class CreateDisputes < ActiveRecord::Migration
  def change
    create_table :disputes do |t|
      t.integer :domain_id, index: true
      t.string :password
      t.datetime :expire_time
      t.datetime :created_at
    end

    add_foreign_key :disputes, :domains
  end
end
