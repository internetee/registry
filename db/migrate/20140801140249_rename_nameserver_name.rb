class RenameNameserverName < ActiveRecord::Migration[6.0]
  def change
    rename_column :nameservers, :name, :hostname
  end
end
