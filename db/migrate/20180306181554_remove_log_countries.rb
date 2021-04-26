class RemoveLogCountries < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_countries
  end
end
