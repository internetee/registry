class AddInvoicesBuyerAddress < ActiveRecord::Migration
  def change
    add_column :invoices, :buyer_address, :string, null: false, default: ''
  end
end