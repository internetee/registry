class AddInvoicesSellerIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :invoices, :registrars, column: :seller_id
  end
end
