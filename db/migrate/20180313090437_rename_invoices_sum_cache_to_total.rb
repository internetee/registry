class RenameInvoicesSumCacheToTotal < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoices, :sum_cache, :total
  end
end
