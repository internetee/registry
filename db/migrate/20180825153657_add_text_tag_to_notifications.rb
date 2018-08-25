class AddTextTagToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :text_tag, :string
  end
end
