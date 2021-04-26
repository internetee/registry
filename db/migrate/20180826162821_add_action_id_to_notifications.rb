class AddActionIdToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :action, foreign_key: true
  end
end
