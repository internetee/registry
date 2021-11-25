class AddConcIndexToContact < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :contacts, :email, :algorithm => :concurrently
  end
end
