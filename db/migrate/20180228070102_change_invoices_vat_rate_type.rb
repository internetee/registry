class ChangeInvoicesVatRateType < ActiveRecord::Migration
  def change
    change_column :invoices, :vat_rate, :decimal, precision: 4, scale: 3
  end
end
