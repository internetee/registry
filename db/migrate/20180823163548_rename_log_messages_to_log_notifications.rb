class RenameLogMessagesToLogNotifications < ActiveRecord::Migration
  def change
    rename_table :log_messages, :log_notifications
  end
end
