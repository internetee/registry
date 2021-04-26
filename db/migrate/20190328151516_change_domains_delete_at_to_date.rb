class ChangeDomainsDeleteAtToDate < ActiveRecord::Migration[6.0]
  def change
    change_column :domains, :delete_at, :date
  end
end
