class AddUpIdValueToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :upid, :string
  end
end
