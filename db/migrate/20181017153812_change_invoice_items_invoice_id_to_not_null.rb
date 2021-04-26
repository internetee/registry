class ChangeInvoiceItemsInvoiceIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoice_items, :invoice_id, false
  end
end
