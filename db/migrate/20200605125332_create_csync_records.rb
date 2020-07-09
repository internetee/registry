class CreateCsyncRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :csync_records do |t|
      t.belongs_to :domain, foreign_key: true, null: false, index: { unique: true }
      t.string :cdnskey, null: false
      t.string :action, null: false
      t.integer :times_scanned, null: false, default: 0
      t.datetime :last_scan, null: false
      t.timestamps
    end
  end
end
