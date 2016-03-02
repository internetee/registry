class AddUpDateValueToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :up_date, :timestamp
  end
end
