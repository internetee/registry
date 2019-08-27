class ChangeInvoicesNumberToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :number, false
  end
end
