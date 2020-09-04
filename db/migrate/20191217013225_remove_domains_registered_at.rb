class RemoveDomainsRegisteredAt < ActiveRecord::Migration[5.0]
  def change
    remove_column :domains, :registered_at
  end
end
