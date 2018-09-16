class RemovePaperTrailColumnsFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :creator_str
    remove_column :invoices, :updator_str
  end
end
