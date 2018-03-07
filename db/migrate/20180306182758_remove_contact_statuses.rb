class RemoveContactStatuses < ActiveRecord::Migration
  def change
    drop_table :contact_statuses
  end
end
