class AddMetainfoToReserveDomainInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_domain_invoices, :metainfo, :string
  end
end
