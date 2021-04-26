class AddUpDateValueToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :up_date, :timestamp
  end
end
