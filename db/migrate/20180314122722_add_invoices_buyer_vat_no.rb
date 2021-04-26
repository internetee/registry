class AddInvoicesBuyerVatNo < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :buyer_vat_no, :string
  end
end
