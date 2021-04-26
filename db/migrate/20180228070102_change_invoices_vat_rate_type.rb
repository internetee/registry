class ChangeInvoicesVatRateType < ActiveRecord::Migration[6.0]
  def change
    change_column :invoices, :vat_rate, :decimal, precision: 4, scale: 3
  end
end
