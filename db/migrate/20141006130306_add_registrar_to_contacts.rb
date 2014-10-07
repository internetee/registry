class AddRegistrarToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :registrar_id, :integer
  end
end
