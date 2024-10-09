class AddVerificationFieldsToContacts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :contacts, :ident_request_sent_at, :datetime
    add_column :contacts, :verified_at, :datetime
    add_index :contacts, :verified_at, algorithm: :concurrently
  end
end
