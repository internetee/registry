class AddLegacyColumnsForDomain < ActiveRecord::Migration
  def change
    add_column :domains, :legacy_id, :integer
    add_column :nameservers, :legacy_domain_id, :integer
  end
end
