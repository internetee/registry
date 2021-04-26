class FixAccountBalancesToDecimal < ActiveRecord::Migration[6.0]
  def change
    change_column :accounts, :balance, :decimal, null: false, default: 0
  end
end
