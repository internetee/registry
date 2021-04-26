class AddSumCacheToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :sum_cache, :decimal
  end
end
