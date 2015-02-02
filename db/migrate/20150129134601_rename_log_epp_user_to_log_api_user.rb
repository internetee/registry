class RenameLogEppUserToLogApiUser < ActiveRecord::Migration
  def change
    rename_table :log_epp_users, :log_api_users
  end
end
