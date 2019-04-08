class RemoveDomainsReserved < ActiveRecord::Migration
  def change
    remove_column :domains, :reserved
  end
end
