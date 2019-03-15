class ChangeInvoiceItemsQuantityToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoice_items, :quantity, false
  end
end
