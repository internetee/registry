class ChangeInvoiceItemsPriceToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoice_items, :price, false
  end
end
