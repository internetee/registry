class RemoveDomainContactsContactType < ActiveRecord::Migration
  def change
    remove_column :domain_contacts, :contact_type, :string
  end
end
