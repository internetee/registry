class RemoveInvoicesPaidAt < ActiveRecord::Migration[6.0]
  def change
    remove_column :invoices, :paid_at
  end
end
