class AddNewAddressFieldsToRegistrar < ActiveRecord::Migration
  def change
    # get rid of old addresses, we will be migrating from the old db soon anyway
    remove_column :registrars, :address, :string
    add_column :registrars, :state, :string
    add_column :registrars, :city, :string
    add_column :registrars, :street, :string
    add_column :registrars, :zip, :string
  end
end
