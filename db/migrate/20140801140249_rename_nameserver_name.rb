class RenameNameserverName < ActiveRecord::Migration
  def change
    rename_column :nameservers, :name, :hostname
  end
end
