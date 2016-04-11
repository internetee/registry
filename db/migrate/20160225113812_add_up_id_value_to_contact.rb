class AddUpIdValueToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :upid, :integer
  end
end
