class ChangeBankTransactionsSumAndCurrencyToNotNull < ActiveRecord::Migration
  def change
    change_column_null :bank_transactions, :sum, false
    change_column_null :bank_transactions, :currency, false
  end
end
