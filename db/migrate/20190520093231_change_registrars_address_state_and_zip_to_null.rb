class ChangeRegistrarsAddressStateAndZipToNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :address_state, true
    change_column_null :registrars, :address_zip, true
  end
end
