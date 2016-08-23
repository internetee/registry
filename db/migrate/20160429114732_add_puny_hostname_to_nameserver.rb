class AddPunyHostnameToNameserver < ActiveRecord::Migration

  def change

    add_column :nameservers, :hostname_puny, :string
    execute "UPDATE nameservers n SET hostname_puny = n.hostname"

  end
end
