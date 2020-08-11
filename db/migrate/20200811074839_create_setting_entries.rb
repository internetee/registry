class CreateSettingEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :setting_entries do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :value, null: false, default: ''
      t.string :group, null: false
      t.string :format, null: false

      # Versioning related
      t.string :creator_str
      t.string :updator_str

      t.timestamps
    end
  end
end
