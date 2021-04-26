class RenameNotificationsQueuedToRead < ActiveRecord::Migration[6.0]
  def change
    rename_column :notifications, :queued, :read
  end
end
