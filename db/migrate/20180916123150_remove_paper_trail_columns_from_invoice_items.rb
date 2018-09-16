class RemovePaperTrailColumnsFromInvoiceItems < ActiveRecord::Migration
  def change
    remove_column :invoice_items, :creator_str
    remove_column :invoice_items, :updator_str
  end
end
