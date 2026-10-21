class AddDeathRegistryIndexesToContacts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :contacts, :death_date, where: 'death_date IS NOT NULL', algorithm: :concurrently
    add_index :contacts, :death_registry_checked_at,
              where: "ident_type = 'priv' AND ident_country_code = 'EE'",
              algorithm: :concurrently
  end
end
