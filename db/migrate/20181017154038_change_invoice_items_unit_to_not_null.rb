class ChangeInvoiceItemsUnitToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoice_items, :unit, false
  end
end
