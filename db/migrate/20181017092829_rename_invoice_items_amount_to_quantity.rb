class RenameInvoiceItemsAmountToQuantity < ActiveRecord::Migration
  def change
    rename_column :invoice_items, :amount, :quantity
  end
end
