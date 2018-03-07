class RemoveLogContactStatuses < ActiveRecord::Migration
  def change
    drop_table :log_contact_statuses
  end
end
