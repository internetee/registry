class PrefixRegistrarsAddressColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :registrars, :street, :address_street
    rename_column :registrars, :zip, :address_zip
    rename_column :registrars, :city, :address_city
    rename_column :registrars, :state, :address_state
    rename_column :registrars, :country_code, :address_country_code
  end
end
