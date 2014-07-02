class CountriesTableRename < ActiveRecord::Migration
  def change
    rename_table :country_id, :countries
  end
end
