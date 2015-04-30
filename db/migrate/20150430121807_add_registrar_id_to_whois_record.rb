class AddRegistrarIdToWhoisRecord < ActiveRecord::Migration
  def change
    add_column :whois_records, :registrar_id, :integer
    add_index :whois_records, :registrar_id
  end
end
