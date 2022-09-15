class AddMonthlyInvoiceTypeColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :monthly_invoice, :boolean, default: false
    add_column :invoices, :metadata, :jsonb
  end
end
