class AddAutoAccountTopUp < ActiveRecord::Migration
  def change
    add_column :registrars, :auto_account_top_up_activated, :boolean, null: false, default: false
    add_column :registrars, :auto_account_top_up_low_balance_threshold, :decimal, precision: 10, scale: 2
    add_column :registrars, :auto_account_top_up_amount, :decimal, precision: 10, scale: 2
    add_column :registrars, :auto_account_top_up_iban, :string
  end
end
