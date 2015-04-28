class AddSumCacheToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :sum_cache, :decimal
    Invoice.all.each(&:save)
  end
end
