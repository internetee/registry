class RenameNotificationsQueuedToRead < ActiveRecord::Migration
  def change
    rename_column :notifications, :queued, :read
  end
end
