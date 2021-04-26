class AddCountryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :country_id, :integer
  end
end
