class ChangeInvoicesVatRateToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :vat_rate, false
  end
end
