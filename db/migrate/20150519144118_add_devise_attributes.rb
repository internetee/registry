class AddDeviseAttributes < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_password, :string, null: true, default: ""
    add_column :users, :remember_created_at, :datetime, null: true
    add_column :users, :failed_attempts, :integer, default: 0, null: false 
    add_column :users, :locked_at, :datetime, null: true
  end
end
