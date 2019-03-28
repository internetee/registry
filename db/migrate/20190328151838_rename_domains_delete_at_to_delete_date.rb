class RenameDomainsDeleteAtToDeleteDate < ActiveRecord::Migration
  def change
    rename_column :domains, :delete_at, :delete_date
  end
end
