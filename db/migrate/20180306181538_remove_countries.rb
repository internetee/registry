class RemoveCountries < ActiveRecord::Migration[6.0]
  def change
    drop_table :countries
  end
end
