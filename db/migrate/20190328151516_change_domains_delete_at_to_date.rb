class ChangeDomainsDeleteAtToDate < ActiveRecord::Migration
  def change
    change_column :domains, :delete_at, :date
  end
end
