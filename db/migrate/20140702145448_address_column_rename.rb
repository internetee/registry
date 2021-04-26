class AddressColumnRename < ActiveRecord::Migration[6.0]
  def change
    rename_column :addresses, :address, :street
  end
end
