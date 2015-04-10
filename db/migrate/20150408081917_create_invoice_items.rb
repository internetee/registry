class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.integer :invoice_id
      # t.string :product_code
      t.string :description, null: false # e-invoice
      t.string :unit
      t.integer :amount
      t.decimal :price

      t.timestamps
    end
  end
end
