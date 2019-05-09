class RemoveInvoicesBuyerAddressParts < ActiveRecord::Migration
  def change
    remove_column :invoices, :buyer_street
    remove_column :invoices, :buyer_zip
    remove_column :invoices, :buyer_city
    remove_column :invoices, :buyer_state
    remove_column :invoices, :buyer_country_code
  end
end