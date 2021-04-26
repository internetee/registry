class RemoveContactStatuses < ActiveRecord::Migration[6.0]
  def change
    drop_table :contact_statuses
  end
end
