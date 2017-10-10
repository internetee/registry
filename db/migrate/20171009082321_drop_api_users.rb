class DropApiUsers < ActiveRecord::Migration
  def change
    drop_table :api_users
    drop_table :log_api_users
  end
end
