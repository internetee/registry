class RemoveBanklinkTransactions < ActiveRecord::Migration[6.0]
  def change
    drop_table :banklink_transactions
  end
end