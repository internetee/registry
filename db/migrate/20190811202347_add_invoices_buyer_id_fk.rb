class AddInvoicesBuyerIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :invoices, :registrars, column: :buyer_id
  end
end
