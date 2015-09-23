class UpdateContactsLogs < ActiveRecord::Migration
  def change
    add_column :log_contacts, :legacy_ident_updated_at, :datetime
  end
end
