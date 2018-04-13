class ChangeInvoicesTotalToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :total, false
  end
end
