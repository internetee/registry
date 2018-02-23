class AddMessagesRegistrarIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :messages, :registrars, name: 'messages_registrar_id_fk'
  end
end
