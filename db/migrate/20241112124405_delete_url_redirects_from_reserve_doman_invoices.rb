class DeleteUrlRedirectsFromReserveDomanInvoices < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :reserve_domain_invoices, :success_business_registry_customer_url
      remove_column :reserve_domain_invoices, :failed_business_registry_customer_url
    end
  end
end
