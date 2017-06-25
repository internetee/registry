class RemoveWhoisRecords < ActiveRecord::Migration
  def up
    drop_table :whois_records
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
