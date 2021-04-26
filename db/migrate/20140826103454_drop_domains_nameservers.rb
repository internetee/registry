class DropDomainsNameservers < ActiveRecord::Migration[6.0]
  def change
    drop_table :domains_nameservers
  end
end
