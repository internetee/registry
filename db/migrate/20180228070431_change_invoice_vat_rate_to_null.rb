class ChangeInvoiceVatRateToNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoices, :vat_rate, true
  end
end
