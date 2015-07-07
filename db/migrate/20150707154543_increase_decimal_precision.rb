class IncreaseDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :account_activities, :sum, :decimal, precision: 10, scale: 2
    change_column :accounts, :balance, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    change_column :bank_transactions, :sum, :decimal, precision: 10, scale: 2
    change_column :banklink_transactions, :vk_amount, :decimal, precision: 10, scale: 2
    change_column :invoice_items, :price, :decimal, precision: 10, scale: 2
    change_column :invoices, :vat_prc, :decimal, precision: 10, scale: 2
    change_column :invoices, :sum_cache, :decimal, precision: 10, scale: 2
  end
end
