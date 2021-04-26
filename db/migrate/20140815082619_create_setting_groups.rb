class CreateSettingGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :setting_groups do |t|
      t.string :code
    end
  end
end
