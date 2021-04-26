class AddAccountActivityBankTransactionIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :account_activities, :bank_transactions
  end
end
