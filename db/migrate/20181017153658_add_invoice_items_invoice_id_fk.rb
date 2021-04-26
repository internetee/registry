class AddInvoiceItemsInvoiceIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :invoice_items, :invoices, name: 'invoice_items_invoice_id_fk'
  end
end
