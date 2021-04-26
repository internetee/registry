class AddDomainContactsContactIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domain_contacts, :contacts, name: 'domain_contacts_contact_id_fk'
  end
end
