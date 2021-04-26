class DropApiUsers < ActiveRecord::Migration[6.0]
  def change
    drop_table :api_users
    drop_table :log_api_users
  end
end
