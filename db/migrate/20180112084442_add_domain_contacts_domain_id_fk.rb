class AddDomainContactsDomainIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :domain_contacts, :domains, name: 'domain_contacts_domain_id_fk'
  end
end
