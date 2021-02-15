class AddNewBalanceToAccountActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :account_activities, :new_balance, :decimal, precision: 10, scale: 2, null: true
  end
end
