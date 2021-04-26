class AddDomainContactsDomainIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domain_contacts, :domains, name: 'domain_contacts_domain_id_fk'
  end
end
