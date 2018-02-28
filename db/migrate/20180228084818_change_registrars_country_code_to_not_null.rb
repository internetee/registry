class ChangeRegistrarsCountryCodeToNotNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :country_code, false
  end
end
