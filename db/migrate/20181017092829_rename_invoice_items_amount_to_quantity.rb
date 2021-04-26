class RenameInvoiceItemsAmountToQuantity < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoice_items, :amount, :quantity
  end
end
