class DropDomainsNameservers < ActiveRecord::Migration
  def change
    drop_table :domains_nameservers
  end
end
