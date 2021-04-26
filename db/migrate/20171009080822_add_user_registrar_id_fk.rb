class AddUserRegistrarIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :users, :registrars, name: 'user_registrar_id_fk'
  end
end
