class AddActionIdToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :action, foreign_key: true
  end
end
