class CreateAccountActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :account_activites do |t|
      t.integer :account_id
      t.integer :invoice_id
      t.decimal :sum
      t.string :currency
      t.integer :bank_transaction_id

      t.timestamps
    end
  end
end
