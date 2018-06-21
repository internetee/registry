class AddUuidToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :uuid, :uuid, default: 'gen_random_uuid()'
  end
end
