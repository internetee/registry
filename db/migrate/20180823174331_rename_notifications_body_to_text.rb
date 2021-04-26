class RenameNotificationsBodyToText < ActiveRecord::Migration[6.0]
  def change
    rename_column :notifications, :body, :text
  end
end
