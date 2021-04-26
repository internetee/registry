class DropLogDomainTransfers < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_domain_transfers
  end
end
