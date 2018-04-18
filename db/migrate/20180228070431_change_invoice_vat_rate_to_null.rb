class ChangeInvoiceVatRateToNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :vat_rate, true
  end
end
