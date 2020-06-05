class CreateCsyncRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :csync_records do |t|
      t.string :domain_name, null: false
      t.integer :times_scanned, null: false, default: 0
      t.datetime :last_scan, null: false
      t.string :cdnskey, null: false
      t.string :cds, null: false

      t.timestamps
    end
  end
end
