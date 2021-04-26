class RenameContactIdentUpdator < ActiveRecord::Migration[6.0]
  def change
    rename_column :contacts,     :legacy_ident_updated_at, :ident_updated_at
    rename_column :log_contacts, :legacy_ident_updated_at, :ident_updated_at
  end
end
