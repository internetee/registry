class NameserversIPsAreArrays < ActiveRecord::Migration
  def change
    change_column :nameservers, :ipv6, "varchar[] USING (string_to_array(ipv6, ','))", default: []
    change_column :nameservers, :ipv4, "varchar[] USING (string_to_array(ipv4, ','))", default: []
  end
end
