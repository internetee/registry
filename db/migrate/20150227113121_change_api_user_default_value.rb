class ChangeApiUserDefaultValue < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :active, nil
  end
end
