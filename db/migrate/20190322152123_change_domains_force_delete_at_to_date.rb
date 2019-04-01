class ChangeDomainsForceDeleteAtToDate < ActiveRecord::Migration
  def change
    change_column :domains, :force_delete_at, :date
  end
end
