class AddWhosiJsonBody < ActiveRecord::Migration
  def change
    add_column :domains, :whois_json, :json
  end
end
