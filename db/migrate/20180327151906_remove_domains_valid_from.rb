class RemoveDomainsValidFrom < ActiveRecord::Migration
  def change
    remove_column :domains, :valid_from, :datetime
  end
end
