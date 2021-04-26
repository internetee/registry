class AddNameserversDomainIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :nameservers, :domains, name: 'nameservers_domain_id_fk'
  end
end
