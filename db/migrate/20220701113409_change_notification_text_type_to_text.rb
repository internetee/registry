class ChangeNotificationTextTypeToText < ActiveRecord::Migration[6.1]
  def change
    change_column :notifications, :text, :text
  end
end
