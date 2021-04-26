class RemoveLogContactStatuses < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_contact_statuses
  end
end
