class RenameDomainsDeleteAtToDeleteDate < ActiveRecord::Migration[6.0]
  def change
    rename_column :domains, :delete_at, :delete_date
  end
end
