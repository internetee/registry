class DropLogDomainTransfers < ActiveRecord::Migration
  def change
    drop_table :log_domain_transfers
  end
end
