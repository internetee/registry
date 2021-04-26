class RemoveInvoicesSellerId < ActiveRecord::Migration[6.0]
  def change
    remove_column :invoices, :seller_id
  end
end
