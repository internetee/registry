class RenameInvoicesSumCacheToTotal < ActiveRecord::Migration
  def change
    rename_column :invoices, :sum_cache, :total
  end
end
