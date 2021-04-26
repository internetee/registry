class CountriesTableRename < ActiveRecord::Migration[6.0]
  def change
    rename_table :country_id, :countries
  end
end
