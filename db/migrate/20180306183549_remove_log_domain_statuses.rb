class RemoveLogDomainStatuses < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_domain_statuses if table_exists?(:log_domain_statuses)
  end
end
