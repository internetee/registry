class RemoveInvoicesInvoiceType < ActiveRecord::Migration
  def change
    remove_column :invoices, :invoice_type, :string
  end
end
