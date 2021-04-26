class AddIpv6ToNameserver < ActiveRecord::Migration[6.0]
  def change
    rename_column :nameservers, :ip, :ipv4
    add_column :nameservers, :ipv6, :string
  end
end
