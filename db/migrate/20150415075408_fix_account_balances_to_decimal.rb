class FixAccountBalancesToDecimal < ActiveRecord::Migration
  def change
    Account.all.each do |x|
      x.balance = 0.0 unless x.balance
      x.save
    end

    change_column :accounts, :balance, :decimal, null: false, default: 0
  end
end
