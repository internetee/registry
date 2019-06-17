class RemoveLogBankTransactions < ActiveRecord::Migration
  def change
    drop_table :log_bank_transactions
  end
end