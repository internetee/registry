class RemoveAddressType < ActiveRecord::Migration[6.0]
  def change
    remove_column :addresses, :type, :string
  end
end
