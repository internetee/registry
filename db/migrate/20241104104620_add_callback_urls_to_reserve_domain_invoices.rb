class AddCallbackUrlsToReserveDomainInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_domain_invoices, :success_business_registry_customer_url, :string
    add_column :reserve_domain_invoices, :failed_business_registry_customer_url, :string
  end
end
