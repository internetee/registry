class AddWhosiJsonBody < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :whois_json, :json
  end
end
