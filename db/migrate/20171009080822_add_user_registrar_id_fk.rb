class AddUserRegistrarIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :users, :registrars, name: 'user_registrar_id_fk'
  end
end
