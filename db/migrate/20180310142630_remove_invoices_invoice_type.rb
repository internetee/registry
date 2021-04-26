class RemoveInvoicesInvoiceType < ActiveRecord::Migration[6.0]
  def change
    remove_column :invoices, :invoice_type, :string
  end
end
