class ChangeInvoicesTotalToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoices, :total, false
  end
end
