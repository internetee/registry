class AddUpDateValueToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :update, :timestamp
  end
end
