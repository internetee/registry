class AddInvoicesBuyerVatNo < ActiveRecord::Migration
  def change
    add_column :invoices, :buyer_vat_no, :string
  end
end
