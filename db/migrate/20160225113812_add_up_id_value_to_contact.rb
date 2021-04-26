class AddUpIdValueToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :upid, :integer
  end
end
