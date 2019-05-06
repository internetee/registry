class ChangeRegistrarsAddressColumnsToNotNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :address_street, false
    change_column_null :registrars, :address_zip, false
    change_column_null :registrars, :address_city, false
    change_column_null :registrars, :address_state, false
  end
end
