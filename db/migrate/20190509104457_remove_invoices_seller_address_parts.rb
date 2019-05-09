class RemoveInvoicesSellerAddressParts < ActiveRecord::Migration
  def change
    remove_column :invoices, :seller_street
    remove_column :invoices, :seller_zip
    remove_column :invoices, :seller_city
    remove_column :invoices, :seller_state
    remove_column :invoices, :seller_country_code
  end
end