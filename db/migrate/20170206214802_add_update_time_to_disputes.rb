class AddUpdateTimeToDisputes < ActiveRecord::Migration
  def change
    add_column :disputes, :updated_at, :datetime
  end
end
