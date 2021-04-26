class AddRegistrarToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :registrar_id, :integer
  end
end
