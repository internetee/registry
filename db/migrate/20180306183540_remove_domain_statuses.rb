class RemoveDomainStatuses < ActiveRecord::Migration
  def change
    drop_table :domain_statuses
  end
end
