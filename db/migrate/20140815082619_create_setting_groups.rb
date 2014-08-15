class CreateSettingGroups < ActiveRecord::Migration
  def change
    create_table :setting_groups do |t|
      t.string :code
    end
  end
end
