class RemoveDomainsValidFrom < ActiveRecord::Migration[6.0]
  def change
    remove_column :domains, :valid_from, :datetime
  end
end
