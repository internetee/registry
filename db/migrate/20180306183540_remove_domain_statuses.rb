class RemoveDomainStatuses < ActiveRecord::Migration[6.0]
  def change
    drop_table :domain_statuses
  end
end
