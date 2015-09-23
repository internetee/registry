class RenameContactIdentUpdator < ActiveRecord::Migration
  def change
    rename_column :contacts,     :legacy_ident_updated_at, :ident_updated_at
    rename_column :log_contacts, :legacy_ident_updated_at, :ident_updated_at
  end
end
