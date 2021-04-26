class ChangeNotificationsReadToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notifications, :read, false
  end
end
