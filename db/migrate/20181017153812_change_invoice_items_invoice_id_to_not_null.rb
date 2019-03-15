class ChangeInvoiceItemsInvoiceIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoice_items, :invoice_id, false
  end
end
