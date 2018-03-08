class RemoveLogCountries < ActiveRecord::Migration
  def change
    drop_table :log_countries
  end
end
