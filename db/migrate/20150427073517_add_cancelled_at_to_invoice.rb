class AddCancelledAtToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :cancelled_at, :datetime
  end
end
