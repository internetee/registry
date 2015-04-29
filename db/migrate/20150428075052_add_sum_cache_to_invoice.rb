class AddSumCacheToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :sum_cache, :decimal
  end
end
