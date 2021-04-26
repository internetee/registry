class RenameMessagesToNotifications < ActiveRecord::Migration[6.0]
  def change
    rename_table :messages, :notifications
  end
end
