class AddWhoisBody < ActiveRecord::Migration
  def change
    add_column :domains, :whois_body, :text
  end
end
