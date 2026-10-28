class AddEventToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :event, :string
  end
end
