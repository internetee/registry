class AddInvoicesSellerAddress < ActiveRecord::Migration
  def change
    add_column :invoices, :seller_address, :string, null: false, default: ''
  end
end