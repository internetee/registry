class AddStreetsToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :street2, :string
    add_column :addresses, :street3, :string
  end
end
