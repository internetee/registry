class AddSentAtToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :sent_at, :datetime
  end
end
