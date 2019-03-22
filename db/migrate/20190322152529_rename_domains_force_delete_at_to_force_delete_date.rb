class RenameDomainsForceDeleteAtToForceDeleteDate < ActiveRecord::Migration
  def change
    rename_column :domains, :force_delete_at, :force_delete_date
  end
end
