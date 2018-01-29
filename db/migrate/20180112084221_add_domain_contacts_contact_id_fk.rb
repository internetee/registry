class AddDomainContactsContactIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :domain_contacts, :contacts, name: 'domain_contacts_contact_id_fk'
  end
end
