class AddCancelledAtToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :cancelled_at, :datetime
  end
end
