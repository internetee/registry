class AddDomainDirectlyToNameserver < ActiveRecord::Migration
  def change
    add_column :nameservers, :domain_id, :integer
    remove_column :nameservers, :ns_set_id
    drop_table :nameservers_ns_sets
    drop_table :ns_sets
  end
end
