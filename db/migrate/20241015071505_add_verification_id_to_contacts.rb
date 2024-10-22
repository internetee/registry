class AddVerificationIdToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :verification_id, :string
  end
end
