class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.integer :registrar_id
      t.string :account_type
      t.decimal :balance

      t.timestamps
    end
  end
end
