class AddUuidToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :uuid, :uuid, default: 'gen_random_uuid()'
  end
end
