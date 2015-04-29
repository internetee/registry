class FixAccountBalancesToDecimal < ActiveRecord::Migration
  def change
    change_column :accounts, :balance, :decimal, null: false, default: 0
  end
end
