class RenameNotificationsBodyToText < ActiveRecord::Migration
  def change
    rename_column :notifications, :body, :text
  end
end
