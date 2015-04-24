class AddWhoisBodyToRegistry < ActiveRecord::Migration
  def change
    create_table :whois_bodies, force: :cascade do |t|
      t.integer  :domain_id
      t.string   :name
      t.text     :whois_body
      t.json     :whois_json
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index  :whois_bodies, :domain_id
    remove_column :domains, :whois_body, :text
    remove_column :domains, :whois_json, :json
  end
end
