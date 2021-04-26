class AddWhoisBody < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :whois_body, :text
  end
end
