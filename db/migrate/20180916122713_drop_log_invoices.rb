class DropLogInvoices < ActiveRecord::Migration
  def change
    drop_table :log_invoices
  end
end
