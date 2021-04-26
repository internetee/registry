class ChangeInvoiceItemsQuantityToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoice_items, :quantity, false
  end
end
