class AddLegacyIdToReservedDomains < ActiveRecord::Migration
  def change
    add_column :reserved_domains, :legacy_id, :integer
  end
end
