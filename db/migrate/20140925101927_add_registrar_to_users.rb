class AddRegistrarToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :registrar_id, :integer
  end
end
