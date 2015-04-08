class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.integer :invoice_id
      # t.string :product_code
      t.string :description, null: false
      t.string :item_unit
      t.integer :item_amount
      t.decimal :item_price

      t.timestamps
    end
  end
end
