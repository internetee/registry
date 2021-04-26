class RenameEppUsersToApiUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table('epp_users', 'api_users')
  end
end
