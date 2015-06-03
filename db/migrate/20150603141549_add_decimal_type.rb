class AddDecimalType < ActiveRecord::Migration
  def change
    {
      'account_activities': ['sum'],
      'accounts': ['balance'],
      'bank_transactions': ['sum'],
      'banklink_transactions': ['vk_amount'],
      'invoice_items': ['price'],
      'invoices': ['vat_prc', 'sum_cache']
    }.each do |table, cols|
      cols.each do |col|
        change_column table, col, :decimal, precision: 8, scale: 2
      end
    end
  end
end
