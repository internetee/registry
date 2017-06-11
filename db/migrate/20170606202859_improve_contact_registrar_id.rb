class ImproveContactRegistrarId < ActiveRecord::Migration
  def change
    add_foreign_key :contacts, :registrars, name: 'contacts_registrar_id_fk'
    change_column :contacts, :registrar_id, :integer, null: false
  end
end
