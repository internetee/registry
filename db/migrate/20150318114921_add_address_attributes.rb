class AddAddressAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :city, :string
    add_column :contacts, :street, :text
    add_column :contacts, :zip, :string
    add_column :contacts, :country_code, :string
    add_column :contacts, :state, :string
  end
end
