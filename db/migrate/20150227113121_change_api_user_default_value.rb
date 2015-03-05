class ChangeApiUserDefaultValue < ActiveRecord::Migration
  def change
    change_column_default :users, :active, nil
  end
end
