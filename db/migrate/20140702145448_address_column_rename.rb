class AddressColumnRename < ActiveRecord::Migration
  def change
    rename_column :addresses, :address, :street, :limit => 11
  end
end
