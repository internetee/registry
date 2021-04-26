class RemoveCountryIdColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrars, :country_id, :integer
    remove_column :users, :country_id, :integer
    remove_column :addresses, :country_id, :integer
  end
end
