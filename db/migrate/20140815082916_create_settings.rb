class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :setting_group_id
      t.string :code
      t.string :value
    end
  end
end
