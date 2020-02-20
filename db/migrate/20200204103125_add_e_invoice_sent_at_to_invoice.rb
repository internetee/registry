class AddEInvoiceSentAtToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :e_invoice_sent_at, :datetime
  end
end
