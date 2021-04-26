class ChangeInvoicesNumberToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoices, :number, false
  end
end
