class DropLogInvoiceItems < ActiveRecord::Migration
  def change
    drop_table :log_invoice_items
  end
end
