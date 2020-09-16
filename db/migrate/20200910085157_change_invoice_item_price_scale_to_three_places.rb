class ChangeInvoiceItemPriceScaleToThreePlaces < ActiveRecord::Migration[6.0]
  def change
    change_column :invoice_items, :price, :decimal, precision: 10, scale: 3
  end
end
