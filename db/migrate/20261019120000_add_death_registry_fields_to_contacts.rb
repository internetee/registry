class AddDeathRegistryFieldsToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :death_date, :date
    add_column :contacts, :death_registry_checked_at, :datetime
  end
end
