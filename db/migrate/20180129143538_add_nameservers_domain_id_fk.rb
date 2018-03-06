class AddNameserversDomainIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :nameservers, :domains, name: 'nameservers_domain_id_fk'
  end
end
