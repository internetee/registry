class AddNameToContact < ActiveRecord::Migration
  def change
    remove_column :addresses, :name, :string
    remove_column :addresses, :org_name, :string
    add_column :contacts, :name, :string
    add_column :contacts, :org_name, :string
  end
end
