class RenameEppUsersToApiUsers < ActiveRecord::Migration
  def change
    rename_table('epp_users', 'api_users')
  end
end
