class AddCountryCodeIdent < ActiveRecord::Migration
  def change
    add_column :contacts, :ident_country_code, :string
  end
end
