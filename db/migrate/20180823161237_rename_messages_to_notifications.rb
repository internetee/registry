class RenameMessagesToNotifications < ActiveRecord::Migration
  def change
    rename_table :messages, :notifications
  end
end
