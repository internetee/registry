class RemoveDomainContactsContactType < ActiveRecord::Migration[6.0]
  def change
    remove_column :domain_contacts, :contact_type, :string
  end
end
