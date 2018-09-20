class ChangeNotificationsReadToNotNull < ActiveRecord::Migration
  def change
    change_column_null :notifications, :read, false
  end
end
