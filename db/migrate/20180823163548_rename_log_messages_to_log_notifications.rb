class RenameLogMessagesToLogNotifications < ActiveRecord::Migration[6.0]
  def change
    rename_table :log_messages, :log_notifications
  end
end
