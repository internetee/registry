class AddStreetsToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :street2, :string
    add_column :addresses, :street3, :string
  end
end
