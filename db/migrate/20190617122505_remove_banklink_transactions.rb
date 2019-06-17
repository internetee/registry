class RemoveBanklinkTransactions < ActiveRecord::Migration
  def change
    drop_table :banklink_transactions
  end
end