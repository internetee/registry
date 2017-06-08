class AddAccountActivityBankTransactionIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :account_activities, :bank_transactions
  end
end
