class AddRegistrarToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registrar_id, :integer
  end
end
