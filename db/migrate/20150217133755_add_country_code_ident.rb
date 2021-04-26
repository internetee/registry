class AddCountryCodeIdent < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :ident_country_code, :string
  end
end
