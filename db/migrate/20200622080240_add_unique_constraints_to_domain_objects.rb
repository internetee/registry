class AddUniqueConstraintsToDomainObjects < ActiveRecord::Migration[6.0]
  def change
    add_index :domain_contacts, [:domain_id, :type, :contact_id], unique: true, name: 'uniq_contact_of_type_per_domain'
    add_index :nameservers, [:domain_id, :hostname], unique: true, name: 'uniq_hostname_per_domain'
  end
end
