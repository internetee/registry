class RemoveDomainsReserved < ActiveRecord::Migration[6.0]
  def change
    remove_column :domains, :reserved
  end
end
