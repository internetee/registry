class RemoveCountryIdColumns < ActiveRecord::Migration
  def change
    remove_column :registrars, :country_id, :integer
    remove_column :users, :country_id, :integer
    remove_column :addresses, :country_id, :integer
  end
end
