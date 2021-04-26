class ChangeInvoiceItemsPriceToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoice_items, :price, false
  end
end
