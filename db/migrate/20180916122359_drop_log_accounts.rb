class DropLogAccounts < ActiveRecord::Migration
  def change
    drop_table :log_accounts
  end
end
