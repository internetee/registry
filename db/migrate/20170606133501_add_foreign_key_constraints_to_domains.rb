class AddForeignKeyConstraintsToDomains < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domains, :registrars, name: 'domains_registrar_id_fk'
    add_foreign_key :domains, :contacts, column: :registrant_id, name: 'domains_registrant_id_fk'
  end
end
