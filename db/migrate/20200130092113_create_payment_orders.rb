class CreatePaymentOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_orders do |t|
      t.string :type, null: false
      t.string :status, default: 0, null: false
      t.belongs_to :invoice, foreign_key: true
      t.jsonb :response, null: true
      t.string :notes, null: true

      t.timestamps
    end
  end
end
