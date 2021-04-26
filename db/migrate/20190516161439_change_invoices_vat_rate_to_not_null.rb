class ChangeInvoicesVatRateToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoices, :vat_rate, false
  end
end
