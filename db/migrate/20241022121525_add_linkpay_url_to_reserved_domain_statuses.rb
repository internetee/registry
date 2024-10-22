class AddLinkpayUrlToReservedDomainStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :reserved_domain_statuses, :linkpay_url, :string, default: ''
  end
end
