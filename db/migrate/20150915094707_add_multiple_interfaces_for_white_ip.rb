class AddMultipleInterfacesForWhiteIp < ActiveRecord::Migration[6.0]
  def change
    change_column :white_ips, :interface, "varchar[] USING (string_to_array(interface, ','))"
    rename_column :white_ips, :interface, :interfaces
  end
end
