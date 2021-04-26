class ChangeInvoiceItemsUnitToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoice_items, :unit, false
  end
end
