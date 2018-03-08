class RemoveLogDomainStatuses < ActiveRecord::Migration
  def change
    drop_table :log_domain_statuses
  end
end
