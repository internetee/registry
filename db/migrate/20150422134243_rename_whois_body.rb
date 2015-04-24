class RenameWhoisBody < ActiveRecord::Migration
  def change
    rename_column :whois_bodies, :whois_body, :body
    rename_column :whois_bodies, :whois_json, :json
    remove_index :whois_bodies, :domain_id
    rename_table :whois_bodies, :whois_records
    add_index :whois_records, :domain_id
  end
end
