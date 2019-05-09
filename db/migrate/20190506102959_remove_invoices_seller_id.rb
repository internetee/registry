class RemoveInvoicesSellerId < ActiveRecord::Migration
  def change
    remove_column :invoices, :seller_id
  end
end
