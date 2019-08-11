class AddInvoicesBuyerIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :invoices, :registrars, column: :buyer_id
  end
end
