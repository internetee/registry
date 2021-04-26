class AddLegacyIdToReservedDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :reserved_domains, :legacy_id, :integer
  end
end
